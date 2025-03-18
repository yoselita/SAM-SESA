;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; NCL Script for "mimicking" a spun-up soil in WRF simualtions          ;
; Contact: j.milovac@uni-hohenheim.de 					; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Instructions: 							;
; To mimic a spun-up soil in the simualtions, variables soil moisture 	;
; variables(SMOIS, TSLB, SH2O), and possibly also snow varaibles.	; 
;			;
; The steps necessary ed to be done before running wrf.exe:		;
;	1. copy this ncl script in the folder where you are about to run;
;	wrf.exe (e.g. ../WRFV3/run/)					;
;	2. Locate the wrfout files from which you want extract the spun ; 
;	up soil								;
;	3. run the script:						;
;       ncl 'file_in="wrfinput_d01"'    			;
;		'file_out="wrfout_d01"' soil_to_wrfinput.ncl;					;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
									
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Adding wrfiput and wrfout file defines in the arguments
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 wrfinput = addfile(file_in+".nc","w")
 wrfout   = addfile(file_out,"r")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Reading SOIL data from a wrfout file, and replacing originals in
; wrfinput files 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SNOWH, QSNOW, SNOW, SNOWNC, SNOWC, ISNOW, QSNOWXY
      SMOIS  = wrfout->SMOIS
      wrfinput->SMOIS(0,:,:,:)=SMOIS(0,:,:,:)
      TSLB  = wrfout->TSLB
      wrfinput->TSLB(0,:,:,:) =TSLB(0,:,:,:)
      SH2O  = wrfout->SH2O   
      wrfinput->SH2O(0,:,:,:) =SH2O(0,:,:,:)

 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Job done! 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end

