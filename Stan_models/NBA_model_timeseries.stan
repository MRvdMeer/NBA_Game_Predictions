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
  for (n in 1:N_games) {
    if (overtime[n] > 0) {
      score_difference[n] = 0;
    } else {
      score_difference[n] = away_points[n] - home_points[n];
    }
  }
}

parameters {
  real team_skill[N_teams, N_games_per_team];
  real<lower = 0> scale;
  real home_court_advantage;
}

transformed parameters {
}

model {
  vector[N_games] skill_difference;
  int position[N_teams];
  position = rep_array(0, N_teams);
  
  for (n in 1:N_games){ //loop over games
    // update game position for playing teams
    position[away_team_id[n]] += 1;
    position[home_team_id[n]] += 1;
    // then find skill difference
    skill_difference[n] = team_skill[away_team_id[n], position[away_team_id[n]]]
    - team_skill[home_team_id[n], position[home_team_id[n]]];
  }
  
  // priors
  scale ~ normal(0, 1);
  team_skill[1,:] ~ normal(0, 4);
  home_court_advantage ~ normal(0, 3);
  
  // likelihood
  score_difference ~ normal(skill_difference - home_court_advantage, scale);
}

generated quantities {
  real score_difference_rep[N_games];
  for (n in 1:N_games) {
    score_difference_rep[n] = normal_rng(skill_difference[n] - home_court_advantage, scale);
  }
}
