/*
The 'story' of this model is that two players play N games
against each other. At the start we have an estimate of both
their skills and a (known) level of uncertainty in these
estimates. After every game, the skills of both players
may change
*/
data {
  int<lower = 1> N;
  int<lower = 0, upper = 1> player1_win[N];
  real player1_skill_est; // current estimate of skill
  real player1_skill_uncertainty; // standard deviation of current skill estimate
  real player2_skill_est; // current estimate of skill
  real player2_skill_uncertainty; // standard deviation of current skill estimate
}
parameters {
  real player1_skill_raw[N];
  real player2_skill_raw[N];
  real<lower = 0> game_uncertainty; // standard deviation of game results
  real<lower = 0> player1_skill_change_scale; // standard deviation of skill updates between games
  real<lower = 0> player2_skill_change_scale; // standard deviation of skill updates between games
}
transformed parameters {
  real player1_skill[N];
  real player2_skill[N];
  real<lower = 0, upper = 1> prob_player1_win[N];
  
  player1_skill[1] = player1_skill_raw[1] * player1_skill_uncertainty + player1_skill_est;
  player2_skill[1] = player2_skill_raw[1] * player2_skill_uncertainty + player2_skill_est;
  prob_player1_win[1] = 1 - normal_cdf(0, player1_skill[1] - player2_skill[1], game_uncertainty);
  
  for (n in 2:N) {
    player1_skill[n] = player1_skill_raw[n] * player1_skill_change_scale + player1_skill[n - 1];
    player2_skill[n] = player2_skill_raw[n] * player2_skill_change_scale + player2_skill[n - 1];
    prob_player1_win[n] = 1 - normal_cdf(0, player1_skill[n] - player2_skill[n], game_uncertainty);
  }
}
model {
  player1_skill_raw ~ normal(0, 1);
  player2_skill_raw ~ normal(0, 1);
  game_uncertainty ~ exponential(0.1);
  player1_skill_change_scale ~ exponential(5); // conservative prior - we don't expect skills to change a lot between games
  player2_skill_change_scale ~ exponential(5);
  player1_win ~ bernoulli(prob_player1_win); // vectorized
}
