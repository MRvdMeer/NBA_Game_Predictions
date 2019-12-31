lookup_team_id <- function(team_name_lookup, mapping_table) {
  # finds team ID from team name and mapping table
  tmp_table <- filter(mapping_table, team_name == team_name_lookup)
  if (nrow(tmp_table) != 1) {
    stop(paste("lookup-rows should be equal to one but found", nrow(tmp_table), "instead"))
  }
  out <- tmp_table$team_id
  out
}

lookup_amount_games_played <- function(game_data, team_mapping_table, N_games_per_team) {
  # generates two columns (for away and home) that keep
  # track of how many games each team has already played
  # in the season
  N_teams <- nrow(team_mapping_table)
  N_games <- nrow(game_data)
  
  tmp <- matrix(0, nrow = N_teams, ncol = N_games)
  away_team_amount_played <- rep(0, N_games)
  home_team_amount_played <- rep(0, N_games)

  for (n in 1:N_games) {
    away_id <- game_data$away_team_id[n]
    home_id <- game_data$home_team_id[n]
    tmp[away_id, n] <- 1
    tmp[home_id, n] <- 1
    away_team_amount_played[n] <- sum(tmp[away_id, 1:n]) - 1
    home_team_amount_played[n] <- sum(tmp[home_id, 1:n]) - 1
  }
  
  out <- game_data %>% mutate(away_played = away_team_amount_played,
                              home_played <- home_team_amount_played)
}

compare_predictions_to_actual <- function(prediction, actual) {
  # predictions is a matrix [iterations x parameters]
  # actual is a vector of length 'parameters'
  # output is a vector of cumulative probabilities, indicating
  # for every observation what the probability is of
  # this actual outcome OR LESS.
  n_out <- length(actual)
  out <- map_dbl(1:n_out, function(i) {mean(prediction[, i] <= actual[i]) })
  out
}

compute_predicted_outcome <- function(prediction) {
  # predictions is a matrix [iterations x parameters]
  # for each predicted game, outcome is one of 
  # -1 (home team wins), 0 (overtime) or 1 (away team wins)
  col_means <- colMeans(prediction)
  sign(round(col_means))
}

print_stanfit_custom_name <- function(stanfit, regpattern, replace_by, ..., ndigits = 3, verbose = TRUE) {
  temp <- summary(stanfit, ...)
  tempsum <- temp$summary
  rn <- rownames(tempsum)
  loc <- grep(pattern = regpattern, rn)
  
  if (length(loc) != length(replace_by)) {
    stop("replacement length not the same as length of replaced values")
  }
  
  rn[loc] <- replace_by
  rownames(tempsum) <- rn
  
  if (verbose) {
    n_kept <- stanfit@sim$n_save - stanfit@sim$warmup2
    sampler <- attr(stanfit@sim$samples[[1]], "args")$sampler_t
    
    cat("Inference for Stan model: ", stanfit@model_name, '.\n', sep = '')
    cat(stanfit@sim$chains, " chains, each with iter=", stanfit@sim$iter,
        "; warmup=", stanfit@sim$warmup, "; thin=", stanfit@sim$thin, "; \n",
        "post-warmup draws per chain=", n_kept[1], ", ",
        "total post-warmup draws=", sum(n_kept), ".\n\n", sep = '')
  }
  
  print(tempsum, digits = ndigits)
  
  if (verbose) {
    cat("\nSamples were drawn using ", sampler, " at ", stanfit@date, ".\n",
        "For each parameter, n_eff is a crude measure of effective sample size,\n",
        "and Rhat is the potential scale reduction factor on split chains (at \n",
        "convergence, Rhat=1).\n", sep = '')
  }
  
  invisible(stanfit)
}


# Example call!

# library(tidyverse)
# library(rstan)
# options(mc.cores = parallel::detectCores())
# rstan_options(auto_write = TRUE)
# set.seed(12)
#
# data <- read_csv(".\\HMMpractice\\MSCI_US_regime_switching_model.csv")
#
# y <- data$return
# N_states <- 2
#
# stan_data_hmm <- list(T = length(y),
#                       N_states = N_states,
#                       y = y)
#
#
# hiddenmarkovmodel <- stan_model(".\\HMMpractice\\HMMorderedsigma.stan")
#
# fit_hmm <- sampling(hiddenmarkovmodel, data = stan_data_hmm, iter = 5000, chains = 4)
#
# print_stanfit_custom_name(fit_hmm, "theta", paste("test", 1:4), pars = c("mu", "sigma", "theta"))
