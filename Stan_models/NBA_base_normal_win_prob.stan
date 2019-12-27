data {
  int<lower = 1> N_games;
  int<lower = 2> N_teams;
  int<lower = 0, upper = 1> home_win[N_games];
  int<lower = 1, upper = N_teams> away_team_id[N_games];
  int<lower = 1, upper = N_teams> home_team_id[N_games];
}

parameters {
  real team_skill[N_teams];
  real<lower = 0> game_uncertainty;
}

transformed parameters {
  vector[N_games] prob_home_win;
  
  for (n in 1:N_games) {
    prob_home_win[n] = 1 - normal_cdf(0, team_skill[home_team_id[n]] - team_skill[away_team_id[n]], game_uncertainty);
  }
}

model {
  // priors
  game_uncertainty ~ normal(0, 1);
  team_skill ~ normal(0, 1);
  
  // likelihood
  home_win ~ bernoulli(prob_home_win);
}

generated quantities {
  real home_win_rep[N_games];
  for (n in 1:N_games) {
    home_win_rep[n] = bernoulli_rng(prob_home_win[n]);
  }
}
