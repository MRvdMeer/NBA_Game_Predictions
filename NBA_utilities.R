lookup_team_id <- function(team_name_lookup, mapping_table) {
  # finds team ID from team name and mapping table
  tmp_table <- filter(mapping_table, team_name == team_name_lookup)
  if (nrow(tmp_table) != 1) {
    stop(paste("lookup-rows should be equal to one but found", nrow(tmp_table), "instead"))
  }
  out <- tmp_table$team_id
  out
}

wrangle_team_skills <- function(data_matrix, ...) {
  # returns a data frame with one column that indicates team 
  # and then one column for each game played
  dimensions <- dim(data_matrix)
  
  skill_matrix <- matrix(0, nrow = N_teams, ncol = N_games_per_team)
  
  NULL
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
  
  data.frame(away_played = away_team_amount_played,
             home_played = home_team_amount_played)
}