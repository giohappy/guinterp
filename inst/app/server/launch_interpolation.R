#   ____________________________________________________________________________
#   Observers used to update the map during interpolation             ####

# check if the manual vgm were defined (if required)
observeEvent(input$interp_button, ignoreInit = TRUE, ignoreNULL = TRUE, {

  # Check if manual VGM still has to be defined
  if (input$interp_method == "krige" & input$auto_vgm == "manual" & is.null(rv$vgm.fit)) {
    rv$fit_vgm_launchgui <- paste0("autoopen_",sample(1E6,1)) # dummy var to open the modaldialog
  } else if (input$interp_method == "krige" & input$auto_vgm == "semiauto" & is.null(rv$vgm.semiauto)) {
    rv$fit_vgm_launchgui <- paste0("autoopen_",sample(1E6,1)) # dummy var to open the modaldialog
  } else {
    rv$interp_canbelaunched <- sample(1E6,1) # dummy var to continue the interpolation
  }
})

# If so, launch the processing
observeEvent(rv$interp_canbelaunched, ignoreInit = TRUE, ignoreNULL = TRUE, {

  # Open waiting message
  show_modal_message(
    shiny::div(
      shiny::p(shiny::HTML(
        ht("_pb_interp_message", i18n)
      )),
      shinyWidgets::progressBar(id = "pb_interp", value = 0, striped = TRUE)
    ),
    title = ht("_pb_interp_title", i18n)
  )


  # Create the file name according to naming conventions ----
  dir.create(rv$interp_dir, showWarnings=FALSE)

  rv$out_raster_paths <- guinterp_process(
    rv$inputpts_points, rv$borders_polygon,
    filtered = TRUE,
    id_fieldname="id_geom",
    interp_dir = rv$interp_dir,
    out_path = rv$outraster_path,
    samplesize = if (input$samplesize_proc_onoff) {input$samplesize_proc} else {Inf},
    samplescheme = input$samplescheme,
    parallel = (input$turbo == "high"),
    interp_method = input$interp_method,
    smooth = input$focal_onoff,
    interp_res = rv$interp_res,
    out_crs = rv$outcrs,
    grid_offset = rv$grid_offset,
    buffer_radius = if (input$maxptdist_onoff) {input$maxptdist} else {Inf},
    vgm = switch(
      input$auto_vgm,
      auto = NA,
      semiauto = rv$vgm.semiauto,
      manual = rv$vgm.fit
    ),
    v_nmax = if (!input$v_nmax_onoff) {input$v_nmax} else {500},
    v_maxdist = if (!input$v_nmax_onoff) {input$v_maxdist} else {NA},
    merge = TRUE,
    overwrite = TRUE, # this after simplifying the GUI
    .shiny_session = session,
    .shiny_pbar_id = "pb_interp"
  )


  # Create a merged raster to be shown
  rv$interp_merged <- if (length(rv$out_raster_paths) > 1) {
    do.call(raster::merge, lapply(rv$out_raster_paths, raster::raster))
  } else {
    lapply(rv$out_raster_paths, raster::raster)[[1]]
  }
  # Change the variable shown
  shinyWidgets::updateRadioGroupButtons(
    session,
    "map_selvariable",
    selected = "selvar"
  )

  # Remove dummy variables used to launch the processing / open a modal
  rv$vgm.fit <- rv$vgm.auto <- NULL
  rv$fit_vgm_launchgui <- NULL
  rv$interp_canbelaunched <- NULL

  # update dummy variable (used to update the map)
  rv$new_interpolation <- if (!is.null(rv$new_interpolation)) {
    rv$new_interpolation + 1
  } else {
    1
  }

  removeModal()

  shinyWidgets::sendSweetAlert(
    session, title = i18n$t("_interp_success_title"),
    text = shiny::div(
      shiny::p(ht("_interp_success_message1", i18n)),
      if (input$outraster_savesingles) {
        shiny::p(
          ht("_interp_success_message2", i18n), tags$br(),
          tags$span(style="font-family:monospace;",rv$interp_dir)
        )
      },
      shiny::p(
        ht("_interp_success_message3", i18n), tags$br(),
        shiny::span(style="font-family:monospace;",rv$outraster_path)
      )
    ),
    type = "success", btn_labels = ht("_Ok", i18n)
  )

})
