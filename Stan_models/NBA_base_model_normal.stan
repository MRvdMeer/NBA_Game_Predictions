data {
  int<lower = 1> N_games;
  int< lower = 2> N_teams;
  real<lower = 0> away_points[N_games];
  real<lower = 0> home_points[N_games];
  int<lower = 0> overtime[N_games];
  int<lower = 1, upper = N_teams> away_team_id[N_games];
  int<lower = 1, upper = N_teams> home_team_id[N_games];
}

transformed data {
  real score_difference[N_games];
  for (n in 1:N_games) {
    if (overtime[n] > 0) {
      score_difference[n] = 0;
    } else {
      score_difference[n] = away_points[n] - home_points[n];
    }
  }
}

parameters {
  real team_skill[N_teams];
  real<lower = 0> stdev;
}

transformed parameters {
  vector[N_games] skill_difference;
  for (n in 1:N_games){
    skill_difference[n] = team_skill[away_team_id[n]] - team_skill[home_team_id[n]];
  }
}

model {
  // no priors
  
  // likelihood
  score_difference ~ normal(skill_difference, stdev);
}

generated quantities {
  real score_difference_rep[N_games];
  for (n in 1:N_games) {
    score_difference_rep[n] = normal_rng(skill_difference[n], stdev);
  }
}
