// Need to update:
// model everything on log scale so sampling doesn't need
// artificial initial values
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
  real<lower = 0> team_skill[N_teams]; // scoring ability per 48 minutes
  real home_court_advantage_raw[N_teams]; // still on a per game scale
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
  team_skill ~ exponential(0.01); // we expect roughly 100 points per 48 minutes
  home_court_advantage_raw ~ normal(0, 1);
  mu_home ~ normal(0, 3);
  sigma_home ~ normal(0, 3);

  // likelihood
  for (n in 1:N_games) {
    away_points[n] ~ poisson(minutes[n] * team_skill[away_team_id[n]]);
    home_points[n] ~ poisson((minutes[n] * team_skill[home_team_id[n]]) + home_court_advantage[home_team_id[n]]);
  }
}

generated quantities {
  int away_score_rep[N_games];
  int home_score_rep[N_games];
  int score_difference_rep[N_games];
  for (n in 1:N_games) {
    away_score_rep[n] = poisson_rng(minutes[n] * team_skill[away_team_id[n]]);
    home_score_rep[n] = poisson_rng(minutes[n] * team_skill[home_team_id[n]] + home_court_advantage[home_team_id[n]]);
    score_difference_rep[n] = away_score_rep[n] - home_score_rep[n];
  }
}
