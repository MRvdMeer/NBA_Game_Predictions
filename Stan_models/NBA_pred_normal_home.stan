data {
  int<lower = 1> N_games;
  int<lower = 2> N_teams;
  real<lower = 0> away_points[N_games];
  real<lower = 0> home_points[N_games];
  int<lower = 0> overtime[N_games];
  int<lower = 1, upper = N_teams> away_team_id[N_games];
  int<lower = 1, upper = N_teams> home_team_id[N_games];
  int<lower = 1> N_new_games;
  int<lower = 1, upper = N_teams> away_id_new[N_new_games];
  int<lower = 1, upper = N_teams> home_id_new[N_new_games];
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
  real home_court_advantage;
}

transformed parameters {
  vector[N_games] skill_difference;
  vector[N_new_games] skill_difference_new;
  for (n in 1:N_games) {
    skill_difference[n] = team_skill[away_team_id[n]] - team_skill[home_team_id[n]];
  }
  
  for (n in 1:N_new_games) {
    skill_difference_new[n] = team_skill[away_id_new[n]] - team_skill[home_id_new[n]];
  }
}

model {
  // priors
  stdev ~ normal(0, 1);
  team_skill ~ normal(0, 4);
  home_court_advantage ~ normal(0, 3);
  
  // likelihood
  score_difference ~ normal(skill_difference - home_court_advantage, stdev);
}

generated quantities {
  real score_difference_pred[N_new_games];
  for (n in 1:N_new_games) {
    score_difference_pred[n] = normal_rng(skill_difference_new[n] - home_court_advantage, stdev);
  }
}
