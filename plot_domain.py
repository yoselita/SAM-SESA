import Ngl,Nio
import numpy as np
import sys
import os

# Python script to be run with 'python3 plot_domain.py argument1 argument2'
# 	argument1= geo_em.nc file, also works with relative or absolute paths
# 	argument2= projection (works with lat-lon and mercator)
# output is a pdf file, located in the working directory

# Reading input, output, projection 
domain = 'SAM'
if len(sys.argv) < 2:
	print("Input not given, cannot continue")
	exit()
elif len(sys.argv) < 3:
	fname=sys.argv[1]  		# geo_em.d01.nc
	projection='lat-lon'		# default is set to 'lat-lon' projection
else:
	fname=sys.argv[1]  		# geo_em.d01.nc
	projection=sys.argv[2] 	#lat-lon, mercator, lambert	
output=os.path.splitext(os.path.basename(fname))[0]

# Reading a variables, lat/lon
file  = Nio.open_file(fname, "r")
var   = file.variables["HGT_M"][0,:,:]
lm    = file.variables["LANDMASK"][0,:,:]
var   = np.where(lm == 0.,-1.,var)
lat2d = file.variables["XLAT_M"][0,:,:]
lon2d = file.variables["XLONG_M"][0,:,:]
nlon  = lon2d.shape[0]
nlat  = lat2d.shape[1]

#Setting the relaxation zone to the missing values
mask = np.full(var.shape, True)
mask[20:nlon-21,20:nlat-21] = False
var = np.ma.masked_array(var, mask)

#Plotting
wks = Ngl.open_wks("pdf",output)

#Map resources
mpres = Ngl.Resources()
mpres.mpGeophysicalLineColor      = "Black"
mpres.mpNationalLineColor         = "Black"
mpres.mpUSStateLineColor          = "Black"
mpres.mpGridLineColor             = "Gray19"
mpres.mpLimbLineColor             = "Black"
mpres.mpPerimLineColor            = "Black"
mpres.mpGeophysicalLineThicknessF = 1.0
mpres.mpGridLineThicknessF        = 1.0
mpres.mpLimbLineThicknessF        = 1.0
mpres.mpNationalLineThicknessF    = 1.0
mpres.mpOutlineBoundarySets       = "AllBoundaries"
mpres.mpDataBaseVersion           = "mediumres"             
mpres.mpDataSetName               = "Earth..4"
mpres.pmTickMarkDisplayMode       = "always" 

#Map resources for rotated grids
if 'lat-lon' in projection.lower():
	if domain == 'SAM':
		rlat, rlon = 70.6-90,180+123.94
	elif domain == 'EUR11':
		rlat, rlon = 90-39.25,18
	elif domain == 'ALP3':
		rlat, rlon = 90-39.25,18
	else:
		print("Domain not recognized, exiting ...")
		exit()
	mpres.mpProjection    = "CylindricalEquidistant"	# for lat-lon projection for SAM domain
	mpres.mpCenterLonF    = rlon 				# 180-$STAND_LON; for lat-lon projection                  
	mpres.mpCenterLatF    = rlat	   			# $POLE_LAT-90.; for lat-lon projection
elif 'mercator' in projection.lower():
	mpres.mpProjection    = "Mercator"  
else:
	print("Projection not recognized, exiting ...")
	exit()
mpres.mpLimitMode            = "Corners"    
mpres.mpLeftCornerLatF       = lat2d[0,0] 
mpres.mpLeftCornerLonF       = lon2d[0,0]
mpres.mpRightCornerLatF      = lat2d[nlon-1,nlat-1]      
mpres.mpRightCornerLonF      = lon2d[nlon-1,nlat-1]
mpres.mpGridAndLimbOn        = True              
mpres.mpGridSpacingF         = 8               
mpres.mpGridLineDashPattern  = 5    
mpres.mpFillOn 		     = True 
mpres.mpMonoFillColor        = True 
mpres.mpFillColor 	     = "Grey"          
mpres.tfDoNDCOverlay         = True    

#General resources
res = mpres
res.nglDraw           = False
res.nglFrame          = False
res.nglMaximize       = True   
     
res.lbOrientation      = "Horizontal"
res.lbLabelPosition    = "Bottom"
res.lbBoxMinorExtentF  = 0.15
res.lbLabelFontHeightF = 0.01 
res.lbTitleOn          = False
res.lbBoxEndCapStyle   = "TriangleHighEnd" 

res.tmXBOn = True 
res.tmXTOn = False  
res.tmYLOn = True  
res.tmYROn = False 

res.cnFillOn             = True             
res.cnFillPalette        = "OceanLakeLandSnow" 	#colormap 
res.cnLinesOn            = False            
res.cnLineLabelsOn       = False            
res.cnLevelSelectionMode = "ExplicitLevels" 	#ManualLevels
res.cnLevels 		 = [0,100,200,300,400,500,600,700,800,900,1000,1100,1200,1500,1800,2100,2500,2900,3300,3700,4100,4500,4800]
res.nglSpreadColors      = False    

# Lat/lon box of interest where we want to average the data
min_lat = -35
max_lat = -17
min_lon = -75
max_lon = -48

# Add a box showing the area of interest
plres = Ngl.Resources()
plres.gsLineColor      = "red"
plres.gsLineThicknessF = 4.0
x = [ min_lon, max_lon, max_lon, min_lon,min_lon ]
y = [ min_lat, min_lat, max_lat, max_lat,min_lat ]

#bplres = plres
#bplres.gsLineColor      = "transparent"
#xb = [ lon2d[20,20], lon2d[nlon-21,20], lon2d[nlon-21,nlat-21], lon2d[20,nlat-21], lon2d[20,20] ]
#yb = [ lat2d[20,20], lat2d[nlon-21,20], lat2d[nlon-21,nlat-21], lat2d[20,nlat-21], lat2d[20,20] ]

#Plotting
plot = Ngl.contour_map (wks,var,res) 
box1  = Ngl.add_polyline(wks, plot, x, y, plres) 
#box2  = Ngl.add_polygon(wks, plot, xb, yb, bplres) 
Ngl.draw(plot)
Ngl.frame(wks)      
Ngl.end() 
