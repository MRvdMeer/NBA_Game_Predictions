// In a previous attempt (see below) we tried modeling this on the log scale
// but that led to strange results.
data {
  int<lower = 1> N_games;
  int<lower = 2> N_teams;
  int<lower = 0> away_points[N_games];
  int<lower = 0> home_points[N_games];
  int<lower = 0> overtime[N_games];
  int<lower = 1, upper = N_teams> away_team_id[N_games];
  int<lower = 1, upper = N_teams> home_team_id[N_games];
}

transformed data {
  real minutes[N_games];
  for (n in 1:N_games){
    minutes[n] = (48.0 + 5.0 * overtime[n]) / 48.0; // on a per-48-minutes scale
  }
}

parameters {
  real<lower = 0> off_skill[N_teams]; // scoring ability per 48 minutes
  real<lower = 0> def_skill[N_teams]; // defensive ability per 48 minutes
  real home_court_advantage_raw[N_teams]; // HCA now affects home and away scoring, per 48 minutes
  real mu_home;
  real<lower = 0> sigma_home;
}

transformed parameters {
  real home_court_advantage[N_teams];
  // non-centered parametrization for hierarchical prior
  for (n in 1:N_teams) {
    home_court_advantage[n] = mu_home + home_court_advantage_raw[n] * sigma_home;
  }
}

model {
  // priors
  off_skill ~ exponential(0.01); // we expect roughly 100 points per 48 minutes
  def_skill ~ exponential(0.1); // longer tail but not nearly as far as offense
  home_court_advantage_raw ~ normal(0, 1);
  mu_home ~ normal(0, 3);
  sigma_home ~ normal(0, 3);

  // likelihood
  for (n in 1:N_games) {
    away_points[n] ~ poisson(minutes[n] * (off_skill[away_team_id[n]] - def_skill[home_team_id[n]]
                                          - home_court_advantage[home_team_id[n]]) );
    home_points[n] ~ poisson(minutes[n] * (off_skill[home_team_id[n]] - def_skill[away_team_id[n]]
                                          + home_court_advantage[home_team_id[n]]) );
  }
}

generated quantities {
  int away_score_rep[N_games];
  int home_score_rep[N_games];
  int score_difference_rep[N_games];
  for (n in 1:N_games) {
    away_score_rep[n] = poisson_rng(minutes[n] * (off_skill[away_team_id[n]] - def_skill[home_team_id[n]]
                                                  - home_court_advantage[home_team_id[n]]) );
    home_score_rep[n] = poisson_rng(minutes[n] * (off_skill[home_team_id[n]] - def_skill[away_team_id[n]]
                                                  + home_court_advantage[home_team_id[n]]) );
    score_difference_rep[n] = away_score_rep[n] - home_score_rep[n];
  }
}


/*
// another attempt on the log scale that doesn't seem to work so well
data {
  int<lower = 1> N_games;
  int< lower = 2> N_teams;
  int<lower = 0> away_points[N_games];
  int<lower = 0> home_points[N_games];
  int<lower = 0> overtime[N_games];
  int<lower = 1, upper = N_teams> away_team_id[N_games];
  int<lower = 1, upper = N_teams> home_team_id[N_games];
}

transformed data {
  real log_minutes[N_games];
  // bring on the log scale
  for (n in 1:N_games){
    log_minutes[n] = log(48.0 + 5.0 * overtime[n]);
  }
}

parameters {
  real log_off_skill[N_teams]; // log of scoring ability per 48 minutes
  real log_def_skill[N_teams]; // log of defensive ability per 48 minutes
  real home_court_advantage_raw[N_teams]; // now on the log scale
  // this means the paramater acts in a multiplicative way and should be close to 0,
  // so that its exp() is close to 1.
  real mu_home;
  real<lower = 0> sigma_home;
}

transformed parameters {
  real home_court_advantage[N_teams];
  // non-centered parametrization for hierarchical prior
  for (n in 1:N_teams) {
    home_court_advantage[n] = mu_home + home_court_advantage_raw[n] * sigma_home;
  }
}

model {
  // priors
  log_off_skill ~ normal(0, 5);
  log_def_skill ~ normal(0, 1);
  home_court_advantage_raw ~ normal(0, 1);
  mu_home ~ normal(0, 1); // home court advantage should be close to 0
  sigma_home ~ normal(0, 2);

  // likelihood
  for (n in 1:N_games) {
    away_points[n] ~ poisson_log(log_minutes[n] + log_off_skill[away_team_id[n]]
                                  - log_def_skill[home_team_id[n]]);
    home_points[n] ~ poisson_log((log_minutes[n] + log_off_skill[home_team_id[n]])
                                  - log_def_skill[away_team_id[n]]
                                  + home_court_advantage[home_team_id[n]]);
  }
}

generated quantities {
  int away_score_rep[N_games];
  int home_score_rep[N_games];
  int score_difference_rep[N_games];
  for (n in 1:N_games) {
    away_score_rep[n] = poisson_log_rng(log_minutes[n] + log_off_skill[away_team_id[n]] - log_def_skill[home_team_id[n]]);
    home_score_rep[n] = poisson_log_rng((log_minutes[n] + log_off_skill[home_team_id[n]]) 
                                  - log_def_skill[away_team_id[n]] + home_court_advantage[home_team_id[n]]);
    score_difference_rep[n] = away_score_rep[n] - home_score_rep[n];
  }
}
*/
