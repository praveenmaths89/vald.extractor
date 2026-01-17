#' Fetch VALD Metadata via OAuth2
#'
#' @title Retrieve Athlete Profiles and Group Assignments
#'
#' @description
#' Authenticates with VALD API using OAuth2 client credentials flow and retrieves
#' complete athlete profile and group membership data. This function handles
#' token management, pagination, and robust JSON parsing.
#'
#' @param client_id Character. Your VALD API client ID.
#' @param client_secret Character. Your VALD API client secret.
#' @param tenant_id Character. Your VALD tenant ID.
#' @param region Character. VALD region code (e.g., "aue" for Australia East).
#'   Default is "aue".
#' @param verbose Logical. If TRUE, prints progress messages. Default is TRUE.
#'
#' @return A list containing two data frames:
#'   \describe{
#'     \item{profiles}{Complete athlete profile data}
#'     \item{groups}{Group/team membership data}
#'   }
#'
#' @export
#'
#' @importFrom httr POST GET add_headers content status_code
#' @importFrom jsonlite fromJSON
#' @importFrom data.table rbindlist
#'
#' @examples
#' \donttest{
#' if (FALSE) {
#'   metadata <- fetch_vald_metadata(
#'     client_id = "your_client_id",
#'     client_secret = "your_client_secret",
#'     tenant_id = "your_tenant_id"
#'   )
#'
#'   profiles <- metadata$profiles
#'   groups <- metadata$groups
#' }
#' }
fetch_vald_metadata <- function(client_id, client_secret, tenant_id,
                                 region = "aue", verbose = TRUE) {

  token_url <- "https://security.valdperformance.com/connect/token"
  profile_base <- "https://prd-aue-api-externalprofile.valdperformance.com"
  tenants_base <- "https://prd-aue-api-externaltenants.valdperformance.com"

  if (verbose) message("Getting access token...")

  token_response <- httr::POST(
    url = token_url,
    body = list(
      grant_type = "client_credentials",
      client_id = client_id,
      client_secret = client_secret
    ),
    encode = "form"
  )

  if (httr::status_code(token_response) != 200) {
    stop("Could not get access token. Status: ", httr::status_code(token_response))
  }

  token_txt <- httr::content(token_response, as = "text", encoding = "UTF-8")
  token_json <- jsonlite::fromJSON(token_txt, simplifyVector = FALSE)
  access_token <- token_json$access_token

  if (is.null(access_token) || access_token == "") {
    stop("access_token not found in token response")
  }

  if (verbose) message("Access token obtained.")

  auth_header <- httr::add_headers(
    Authorization = paste("Bearer", access_token),
    Accept = "application/json"
  )

  if (verbose) message("--- Fetching profiles... ---")

  list_api_url <- paste0(profile_base, "/profiles")
  get_response <- httr::GET(
    url = list_api_url,
    query = list(TenantId = tenant_id),
    auth_header
  )

  if (httr::status_code(get_response) != 200) {
    stop("Could not get profile list. Status: ", httr::status_code(get_response))
  }

  profiles_txt <- httr::content(get_response, as = "text", encoding = "UTF-8")
  profiles_json <- jsonlite::fromJSON(profiles_txt, simplifyVector = FALSE)

  if (!is.null(profiles_json$profiles)) {
    all_profiles_list <- profiles_json$profiles
  } else if (is.list(profiles_json) && length(profiles_json) > 0) {
    all_profiles_list <- profiles_json
  } else {
    all_profiles_list <- list()
  }

  if (verbose) message("Found ", length(all_profiles_list), " profiles in master list.")

  full_profile_details <- list()
  profile_api_url <- paste0(profile_base, "/profiles/")

  if (verbose) message("Fetching full details for each profile...")

  if (length(all_profiles_list) > 0) {
    for (i in seq_along(all_profiles_list)) {
      profile_item <- all_profiles_list[[i]]
      profile_id <- profile_item$profileId
      if (is.null(profile_id)) profile_id <- profile_item$id
      if (is.null(profile_id)) next

      current_url <- paste0(profile_api_url, profile_id)
      response <- httr::GET(
        url = current_url,
        query = list(tenantId = tenant_id),
        auth_header
      )

      if (httr::status_code(response) == 200) {
        resp_txt <- httr::content(response, as = "text", encoding = "UTF-8")
        parsed <- tryCatch(
          jsonlite::fromJSON(resp_txt, simplifyVector = FALSE),
          error = function(e) NULL
        )
        full_profile_details[[as.character(profile_id)]] <- parsed
      }

      Sys.sleep(0.25)
    }
  }

  if (verbose) message("Profile fetch complete!")

  Profile_meta <- if (length(full_profile_details) > 0) {
    as.data.frame(data.table::rbindlist(
      full_profile_details,
      use.names = TRUE,
      fill = TRUE,
      idcol = "profileId_from_list"
    ))
  } else {
    data.frame()
  }

  if (verbose) message("--- Fetching groups... ---")

  groups_list_api_url <- paste0(tenants_base, "/groups")
  get_groups_response <- httr::GET(
    url = groups_list_api_url,
    query = list(TenantId = tenant_id),
    auth_header
  )

  if (httr::status_code(get_groups_response) != 200) {
    stop("Could not get group list. Status: ", httr::status_code(get_groups_response))
  }

  groups_txt <- httr::content(get_groups_response, as = "text", encoding = "UTF-8")
  groups_json <- jsonlite::fromJSON(groups_txt, simplifyVector = FALSE)

  if (!is.null(groups_json$groups)) {
    all_groups_list <- groups_json$groups
  } else if (is.list(groups_json) && length(groups_json) > 0) {
    all_groups_list <- groups_json
  } else {
    all_groups_list <- list()
  }

  if (verbose) message("Found ", length(all_groups_list), " groups in master list.")

  full_group_details <- list()
  groups_api_url <- paste0(tenants_base, "/groups/")

  if (verbose) message("Fetching full details for each group...")

  if (length(all_groups_list) > 0) {
    for (i in seq_along(all_groups_list)) {
      grp_item <- all_groups_list[[i]]
      grp_id <- grp_item$id
      if (is.null(grp_id)) grp_id <- grp_item$groupId
      if (is.null(grp_id)) next

      current_url <- paste0(groups_api_url, grp_id)
      response <- httr::GET(
        url = current_url,
        query = list(tenantId = tenant_id),
        auth_header
      )

      if (httr::status_code(response) == 200) {
        resp_txt <- httr::content(response, as = "text", encoding = "UTF-8")
        parsed <- tryCatch(
          jsonlite::fromJSON(resp_txt, simplifyVector = FALSE),
          error = function(e) NULL
        )
        full_group_details[[as.character(grp_id)]] <- parsed
      }

      Sys.sleep(0.25)
    }
  }

  if (verbose) message("Group fetch complete!")

  Groups_meta <- if (length(full_group_details) > 0) {
    as.data.frame(data.table::rbindlist(
      full_group_details,
      use.names = TRUE,
      fill = TRUE,
      idcol = "groupId_from_list"
    ))
  } else {
    data.frame()
  }

  return(list(
    profiles = Profile_meta,
    groups = Groups_meta
  ))
}


#' Standardize VALD Metadata
#'
#' @title Create Unified Athlete Metadata with Group Assignments
#'
#' @description
#' Processes raw profile and group data to create a clean, analysis-ready metadata
#' table. Unnests group memberships, concatenates group names, and applies
#' sports classification logic.
#'
#' @param profiles Data frame. Raw profile data from \code{fetch_vald_metadata()}.
#' @param groups Data frame. Raw group data from \code{fetch_vald_metadata()}.
#' @param verbose Logical. If TRUE, prints progress messages. Default is TRUE.
#'
#' @return A data frame with one row per athlete containing:
#'   \describe{
#'     \item{profileId}{Unique athlete identifier}
#'     \item{givenName, familyName}{Athlete names}
#'     \item{dateOfBirth, sex}{Demographic information}
#'     \item{all_group_names}{Comma-separated list of all group memberships}
#'     \item{all_group_ids}{Comma-separated list of all group IDs}
#'   }
#'
#' @export
#'
#' @importFrom dplyr mutate group_by summarise left_join select rename across
#' @importFrom dplyr %>%
#' @importFrom tidyr unnest_longer
#'
#' @examples
#' \donttest{
#' if (FALSE) {
#'   metadata <- fetch_vald_metadata(client_id, client_secret, tenant_id)
#'   clean_metadata <- standardize_vald_metadata(
#'     profiles = metadata$profiles,
#'     groups = metadata$groups
#'   )
#' }
#' }
standardize_vald_metadata <- function(profiles, groups, verbose = TRUE) {

  if (!"groupId" %in% names(groups)) {
    if ("id" %in% names(groups)) {
      groups <- dplyr::rename(groups, groupId = id)
    } else {
      stop("Groups data must contain 'groupId' or 'id' column")
    }
  }

  if (!"name" %in% names(groups)) {
    groups$name <- NA_character_
  }

  possible_profile_id_cols <- c("profileId", "id", "profileId_from_list", "ProfileId")
  profile_id_col <- intersect(possible_profile_id_cols, names(profiles))[1]

  if (is.null(profile_id_col)) {
    stop("No profile id column found. Expected one of: ",
         paste(possible_profile_id_cols, collapse = ", "))
  }

  if (verbose) message("Using profile id column: ", profile_id_col)

  if (!"groupIds" %in% names(profiles)) {
    profiles$groupIds <- vector("list", nrow(profiles))
  }

  profiles_long_df <- profiles %>%
    dplyr::mutate(
      profileId = as.character(.data[[profile_id_col]]),
      groupIds = lapply(groupIds, function(x) if (is.null(x)) NA_character_ else x)
    ) %>%
    tidyr::unnest_longer(groupIds, keep_empty = TRUE) %>%
    dplyr::mutate(groupIds = as.character(groupIds))

  groups_df <- groups %>%
    dplyr::mutate(groupId = as.character(groupId)) %>%
    dplyr::select(groupId, name, dplyr::everything())

  merged_df <- profiles_long_df %>%
    dplyr::left_join(groups_df, by = c("groupIds" = "groupId"))

  identity_cols_wanted <- c("profileId", "givenName", "familyName",
                            "dateOfBirth", "sex", "email", "weightInKg", "heightInCm")
  identity_cols <- intersect(identity_cols_wanted, names(merged_df))

  missing_identity <- setdiff(identity_cols_wanted, identity_cols)
  if (length(missing_identity) > 0) {
    for (col in missing_identity) merged_df[[col]] <- NA
    identity_cols <- identity_cols_wanted
  }

  unique_athletes_df <- merged_df %>%
    dplyr::group_by(dplyr::across(dplyr::all_of(identity_cols))) %>%
    dplyr::summarise(
      all_group_names = {
        v <- unique(stats::na.omit(name))
        if (length(v) == 0) NA_character_ else paste(v, collapse = ", ")
      },
      all_group_ids = {
        v <- unique(stats::na.omit(groupIds))
        if (length(v) == 0) NA_character_ else paste(v, collapse = ", ")
      },
      .groups = "drop"
    )

  if (verbose) message("Metadata standardization complete. Rows: ", nrow(unique_athletes_df))

  return(unique_athletes_df)
}


#' Classify Sports from Group Names
#'
#' @title Automated Sports Taxonomy Mapping
#'
#' @description
#' Applies regex-based pattern matching to standardize inconsistent sport/team
#' naming conventions into a clean categorical variable. This is the core
#' "value-add" for multi-sport organizations where team names may vary
#' (e.g., "Football", "Soccer", "FSI" all map to "Football").
#'
#' @param data Data frame containing athlete metadata.
#' @param group_col Character. Name of the column containing group/team names.
#'   Default is "all_group_names".
#' @param output_col Character. Name for the new standardized sports column.
#'   Default is "sports_clean".
#'
#' @return Data frame with an additional column containing standardized sports categories.
#'
#' @export
#'
#' @importFrom dplyr mutate case_when
#' @importFrom dplyr %>%
#' @importFrom stringr str_detect regex
#'
#' @examples
#' \donttest{
#' if (FALSE) {
#'   metadata <- standardize_vald_metadata(profiles, groups)
#'   metadata <- classify_sports(metadata)
#'   table(metadata$sports_clean)
#' }
#' }
classify_sports <- function(data, group_col = "all_group_names",
                           output_col = "sports_clean") {

  data %>%
    dplyr::mutate(
      !!output_col := dplyr::case_when(
        stringr::str_detect(.data[[group_col]], stringr::regex("Football|FSI|TCFC|MCFC", ignore_case = TRUE)) ~ "Football",
        stringr::str_detect(.data[[group_col]], stringr::regex("Badminton", ignore_case = TRUE)) ~ "Badminton",
        stringr::str_detect(.data[[group_col]], stringr::regex("Basketball", ignore_case = TRUE)) ~ "Basketball",
        stringr::str_detect(.data[[group_col]], stringr::regex("Cricket", ignore_case = TRUE)) ~ "Cricket",
        stringr::str_detect(.data[[group_col]], stringr::regex("Racquet", ignore_case = TRUE)) ~ "Racquet Sports",
        stringr::str_detect(.data[[group_col]], stringr::regex("Tennis", ignore_case = TRUE)) ~ "Tennis",
        stringr::str_detect(.data[[group_col]], stringr::regex("Swim", ignore_case = TRUE)) ~ "Swimming",
        stringr::str_detect(.data[[group_col]], stringr::regex("Track|Field", ignore_case = TRUE)) ~ "Track & Field",
        stringr::str_detect(.data[[group_col]], stringr::regex("Skaters", ignore_case = TRUE)) ~ "Skating",
        stringr::str_detect(.data[[group_col]], stringr::regex("Runner|Runners", ignore_case = TRUE)) ~ "Running",
        stringr::str_detect(.data[[group_col]], stringr::regex("Golf", ignore_case = TRUE)) ~ "Golf",
        stringr::str_detect(.data[[group_col]], stringr::regex("Weight", ignore_case = TRUE)) ~ "Weightlifting",
        stringr::str_detect(.data[[group_col]], stringr::regex("Return to Sports|ACL", ignore_case = TRUE)) ~ "Rehab / Return-to-Sport",
        stringr::str_detect(.data[[group_col]], stringr::regex("Clinic Data", ignore_case = TRUE)) ~ "General Public",
        stringr::str_detect(.data[[group_col]], stringr::regex("All Sports", ignore_case = TRUE)) ~ "All_Sports",
        TRUE ~ "All_Sports"
      )
    )
}
