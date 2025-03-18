;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; geogrid_to_cf.ncl
; command syntax:
;   ncl 'file_in="file_in.nc"' 'file_out="wrfout.nc"' "domain="d01"' to_cf.ncl
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; load in the libraries
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; procedure to process the attributes in creating CF compliant WRF output
procedure assignVarAttCoord(x:numeric)
begin
  ; assign the default missing value
  MissingValue = 1e20  
  x!0 = "rlat"
  x!1 = "rlon"
  x@_FillValue = MissingValue
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; start the primary wrfout_to_cf.ncl program
begin
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; configuration settings
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  limS_N  = (/0,9999/)
  limW_E  = (/0,9999/)

  ; set default values for file_in, dir_in, and file_out, if not specified
  if (.not.isvar("file_in")) then
    print("file_in not given, cannot continue")
  end if
  if (.not.isvar("file_out")) then
    print("file_out not given, cannot continue")
  end if
  if (.not.isvar("domain")) then
   domain="d01"
  end if
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;; set the flags for selecting variables to be included ;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; set the netcdf file global attributes
  fileAtt                = True
  fileAtt@creation_date  = systemfunc("date")
  fileAtt@institution    = "UCAN-IFCA"
  fileAtt@notes          = "Created with NCL script:  wrfout_to_cf.ncl v2.0.3"
  fileAtt@source         = file_in
  fileAtt@output         = file_out
  fileAtt@Conventions    = "CF 1.6, Standard Name Table v19"
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; open the input netcdf file (wrfout file)
  wrfout = addfile(file_in+".nc","r")     
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; two-dimensional mapping variables
  if (file_in.eq."geo_em."+domain+".nc") then
    lat = todouble(wrfout->XLAT_M(0,:,:))        ;lat (mass)
    lon = todouble(wrfout->XLONG_M(0,:,:))       ;lon (mass)
  else if (file_in.eq."source.nc") then
    lat = todouble(wrfout->XLAT(:,:))        ;lat (mass)
    lon = todouble(wrfout->XLONG(:,:))       ;lon (mass)
  else
    lat = todouble(wrfout->XLAT(0,:,:))        ;lat (mass)
    lon = todouble(wrfout->XLONG(0,:,:))       ;lon (mass)
  end if
  end if
    ;delete_VarAtts(lat,-1)
    DimLat = dimsizes(lat)
    nS_N = DimLat(0)               		;S_N dimension
    nW_E = DimLat(1)               		;W_E dimension
    lat@long_name = "Latitude"
    lat@standard_name = "latitude"
    lat@units = "degrees_north"
    lat!0 = "rlat"
    lat!1 = "rlon"
    ;delete_VarAtts(lon,-1)
    lon@long_name = "Longitude"
    lon@standard_name = "longitude"
    lon@units = "degrees_east"
    lon!0 = "rlat"
    lon!1 = "rlon"     
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; two-dimensional surface/soil variables
  sftls = wrfout->LANDMASK(0,:,:)      	;land mask (1 - land, 0 - water)
     delete_VarAtts(sftls,-1)
     sftls@long_name = "Land mask"
     sftls@standard_name = "land_mask"
     sftls@units = ""
     sftls@notes = "1=land, 0=water"
     assignVarAttCoord(sftls)    
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;check the limits for the output arrays, set 9999 to end of dataset
  if (limS_N(1) .eq. 9999) then 
    limS_N(1) = nS_N-1
  end if
  if (limW_E(1) .eq. 9999) then 
    limW_E(1) = nW_E-1
  end if  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;; write post-processed WRF data to netCDF file ;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; create empty output file
  if (isfilepresent(file_out)) then
    system("rm " + file_out )
  end if
  wrfpost = addfile(file_out,"c")   
  ; create the global attributes
  fileattdef(wrfpost, fileAtt)
  ; -two-dimensional mapping variables
  wrfpost->lat=lat(limS_N(0):limS_N(1),limW_E(0):limW_E(1))
  wrfpost->lon=lon(limS_N(0):limS_N(1),limW_E(0):limW_E(1))
  wrfpost->sftls=sftls(limS_N(0):limS_N(1),limW_E(0):limW_E(1)) 
end

