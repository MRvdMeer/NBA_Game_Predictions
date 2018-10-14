data {
  int<lower = 1> N_games;
  int<lower = 2> N_teams;
  int<lower = 1> N_games_per_team;
  real<lower = 0> away_points[N_games];
  real<lower = 0> home_points[N_games];
  int<lower = 0> overtime[N_games];
  int<lower = 1, upper = N_teams> away_team_id[N_games];
  int<lower = 1, upper = N_teams> home_team_id[N_games];
}

transformed data {
  real score_difference[N_games];
  // counters count the nth game in the season
  // for the away and home teams
  int<lower = 1, upper = N_games_per_team> away_counter[N_games];
  int<lower = 1, upper = N_games_per_team> home_counter[N_games];
  int<lower = 0, upper = N_games_per_team> position[N_teams] = rep_array(0, N_teams);
  for (n in 1:N_games) {
    if (overtime[n] > 0) {
      score_difference[n] = 0;
    } else {
      score_difference[n] = away_points[n] - home_points[n];
    }
    position[away_team_id[n]] += 1;
    position[home_team_id[n]] += 1;
    away_counter[n] = position[away_team_id[n]];
    home_counter[n] = position[home_team_id[n]];
  }
}

parameters {
  real team_skill_raw[N_teams, N_games_per_team]; // for non-centered parametrization
  real<lower = 0> score_scale;
  real<lower = 0> init_scale;
  real<lower = 0> update_scale;
  real home_court_advantage;
}

transformed parameters {
  real team_skill[N_teams, N_games_per_team];
  vector[N_games] skill_difference;
  
  for (n in 1:N_teams) {
    team_skill[n, 1] = init_scale * team_skill_raw[n, 1];
    for (i in 2:N_games_per_team) {
      team_skill[n, i] = team_skill[n, i - 1] + update_scale * team_skill_raw[n, i];
    }
  }
  // this code calculates the skill difference at the time of the game
  // since away team and home team might have already played a different
  // number of games this complicated setup with the counters is necessary.
  for (n in 1:N_games){
    skill_difference[n] = team_skill[away_team_id[n], away_counter[n]]
    - team_skill[home_team_id[n], home_counter[n]];
  }
}

model {
  // priors
  score_scale ~ normal(0, 1);
  init_scale ~ normal(0,1);
  update_scale ~ normal(0, 1);
  home_court_advantage ~ normal(0, 3);
  
  for (n in 1:N_teams) {
    //for (i in 1:N_games_per_team) {
    team_skill_raw[n, :] ~ normal(0, 1);
    //}
  }
  
  // likelihood
  score_difference ~ normal(skill_difference - home_court_advantage, score_scale);
}

generated quantities {
  real score_difference_rep[N_games];
  for (n in 1:N_games) {
    score_difference_rep[n] = normal_rng(skill_difference[n] - home_court_advantage, score_scale);
  }
}
