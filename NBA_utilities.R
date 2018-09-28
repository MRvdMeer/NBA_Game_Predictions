lookup_team_id <- function(team_name_lookup, mapping_table) {
  tmp_table <- filter(mapping_table, team_name == team_name_lookup)
  if (nrow(tmp_table) != 1) {
    stop(paste("lookup-rows should be equal to one but found", nrow(tmp_table), "instead"))
  }
  out <- tmp_table$team_id
  out
}