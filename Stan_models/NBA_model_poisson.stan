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
}

parameters {
  real<lower=0> team_skill[N_teams];
  real home_court_advantage;
}

transformed parameters {
}

model {
  // priors
  team_skill ~ normal(0, 4);

  // likelihood
  for (n in 1:N_games){
    away_points[n] ~ poisson(team_skill[away_team_id[n]]);
    home_points[n] ~ poisson(team_skill[home_team_id[n]] + home_court_advantage);
  }
}

generated quantities {
  int away_score_rep[N_games];
  int home_score_rep[N_games];
  int score_difference_rep[N_games];
  for (n in 1:N_games) {
    away_score_rep[n] = poisson_rng(team_skill[away_team_id[n]]);
    home_score_rep[n] = poisson_rng(team_skill[home_team_id[n]] + home_court_advantage);
    score_difference_rep[n] = away_score_rep[n] - home_score_rep[n];
  }
}
