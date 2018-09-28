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
  // real<lower = 0> team_skill[N_teams];
  real team_skill[N_teams];
  real<lower = 0> scale;
  real<lower = 0> deg_free;
  real home_court_advantage;
}

transformed parameters {
  vector[N_games] skill_difference;
  for (n in 1:N_games){
    skill_difference[n] = team_skill[away_team_id[n]] - team_skill[home_team_id[n]];
  }
}

model {
  // priors
  deg_free ~ gamma(2, 0.2);
  scale ~ normal(0, 1);
  team_skill ~ normal(0, 4);
  home_court_advantage ~ normal(0, 4);
  
  // likelihood
  score_difference ~ student_t(deg_free, skill_difference - home_court_advantage, scale);
}

generated quantities {
  real score_difference_rep[N_games];
  for (n in 1:N_games) {
    score_difference_rep[n] = student_t_rng(deg_free, skill_difference[n] - home_court_advantage, scale);
  }
}
