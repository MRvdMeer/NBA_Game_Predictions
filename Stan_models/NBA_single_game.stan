data{
  int<lower = 0, upper = 1> home_win;
}

parameters {
  real home_skill;
  real away_skill;
  real<lower = 0> game_uncertainty;
}

transformed parameters {
  real<lower = 0, upper = 1> prob_home_win = 1 - normal_cdf(0, home_skill - away_skill, game_uncertainty);
}

model {
  home_skill ~ normal(0, 1);
  away_skill ~ normal(0, 1);
  game_uncertainty ~ normal(0, 1);
  home_win ~ bernoulli(prob_home_win);
}
