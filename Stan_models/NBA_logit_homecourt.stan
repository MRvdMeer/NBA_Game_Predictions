data {
  int<lower = 1> N_games;
  int<lower = 2> N_teams;
  int<lower = 0, upper = 1> home_win[N_games];
  int<lower = 1, upper = N_teams> away_team_id[N_games];
  int<lower = 1, upper = N_teams> home_team_id[N_games];
}

parameters {
  real team_skill[N_teams];
  real home_court_advantage;
}

transformed parameters {
  vector[N_games] logit_prob_home_win;
  
  for (n in 1:N_games) {
    logit_prob_home_win[n] = team_skill[home_team_id[n]] + home_court_advantage - team_skill[away_team_id[n]];
  }
}

model {
  // priors
  team_skill ~ normal(0, 1);
  home_court_advantage ~ normal(0.3, 0.2); // old version: normal(0, 1)
  
  // likelihood
  home_win ~ bernoulli_logit(logit_prob_home_win);
}

generated quantities {
  int home_win_rep[N_games];
  for (n in 1:N_games) {
    home_win_rep[n] = bernoulli_logit_rng(logit_prob_home_win[n]);
  }
}
