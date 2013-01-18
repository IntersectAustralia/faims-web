import sys
import ogr
import osr

ds = ogr.Open("KAZ_Scatters.shp")
if ds is None:
    print "Open failed.\n"
    sys.exit( 1 )

lyr = ds.GetLayerByIndex(0)

lyr.ResetReading()

f = open("KAZ_Scatters.prj")
wkt = f.read()
f.close()

sRef = osr.SpatialReference()
dRef = osr.SpatialReference()

sRef.ImportFromWkt(wkt)
dRef.ImportFromWkt('PROJCS["WGS 84 / Pseudo-Mercator",GEOGCS["Popular Visualisation CRS",DATUM["Popular_Visualisation_Datum",SPHEROID["Popular Visualisation Sphere",6378137,0,AUTHORITY["EPSG","7059"]],TOWGS84[0,0,0,0,0,0,0],AUTHORITY["EPSG","6055"]],PRIMEM["Greenwich",0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.01745329251994328,AUTHORITY["EPSG","9122"]],AUTHORITY["EPSG","4055"]],UNIT["metre",1,AUTHORITY["EPSG","9001"]],PROJECTION["Mercator_1SP"],PARAMETER["central_meridian",0],PARAMETER["scale_factor",1],PARAMETER["false_easting",0],PARAMETER["false_northing",0],AUTHORITY["EPSG","3785"],AXIS["X",EAST],AXIS["Y",NORTH]]')

print sRef.ExportToWkt()
print dRef.ExportToWkt()

transform = osr.CoordinateTransformation(sRef, dRef)

f = open('KAZ_Scatters.wkb', 'wb')

for feat in lyr:
    geom = feat.GetGeometryRef()
    geom.Transform(transform)
    print geom.ExportToWkt()
    wkb = geom.ExportToWkb()
    f.write(wkb)

ds = None
f.close()