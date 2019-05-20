data {
  int<lower=0, upper=1> home_win;
  real home_skill_est;
  real home_skill_uncertainty;
  real away_skill_est;
  real away_skill_uncertainty;
  real<lower=0> game_uncertainty;
}

parameters {
  real home_skill_raw;
  real away_skill_raw;
}

transformed parameters {
  real home_skill = home_skill_raw * home_skill_uncertainty + home_skill_est;
  real away_skill = away_skill_raw * away_skill_uncertainty + away_skill_est;
  real<lower = 0, upper = 1> prob_home_win = 1 - normal_cdf(0, home_skill - away_skill, game_uncertainty);
}

model {
  home_skill_raw ~ normal(0, 1);
  away_skill_raw ~ normal(0, 1);
  game_uncertainty ~ exponential(0.1);
  home_win ~ bernoulli(prob_home_win);
}
