#! /usr/bin/python

import sys
import os
import argparse
import ogr
import osr

class SHPExporter:

    FAIMS_PROJ_WKT = 'PROJCS["WGS 84 / Pseudo-Mercator",GEOGCS["Popular Visualisation CRS",DATUM["Popular_Visualisation_Datum",SPHEROID["Popular Visualisation Sphere",6378137,0,AUTHORITY["EPSG","7059"]],TOWGS84[0,0,0,0,0,0,0],AUTHORITY["EPSG","6055"]],PRIMEM["Greenwich",0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.01745329251994328,AUTHORITY["EPSG","9122"]],AUTHORITY["EPSG","4055"]],UNIT["metre",1,AUTHORITY["EPSG","9001"]],PROJECTION["Mercator_1SP"],PARAMETER["central_meridian",0],PARAMETER["scale_factor",1],PARAMETER["false_easting",0],PARAMETER["false_northing",0],AUTHORITY["EPSG","3785"],AXIS["X",EAST],AXIS["Y",NORTH]]'

    @staticmethod
    def export_dir(dirname, verbose):
        if os.path.isdir(dirname) == False:
            print "Error: " + dirname + " does not exist"
            return

        if dirname.endswith("/") == False:
            dirname = dirname + "/"

        for root, dirs, files in os.walk(dirname): # Walk directory tree
            for f in files:
                if f.endswith(".shp"):

                    SHPExporter.export_file(dirname, f, verbose)

    @staticmethod
    def export_file(dirname, filename, verbose):

        filepath = dirname + filename
        filepathNoExt = os.path.splitext(filepath)[0]

        if os.path.isfile(filepath) == False:
            print "Error: " + filename + " does not exist"
            return

        # get shape projection
        f = open(filepathNoExt + ".prj")
        proj_wkt = f.read()
        f.close()

        # create transform
        sRef = osr.SpatialReference()
        dRef = osr.SpatialReference()

        sRef.ImportFromWkt(proj_wkt)
        dRef.ImportFromWkt(SHPExporter.FAIMS_PROJ_WKT)

        #print sRef.ExportToWkt()
        #print dRef.ExportToWkt()

        transform = osr.CoordinateTransformation(sRef, dRef)

        # export file
        ds = ogr.Open(filepath)
        if ds is None:
            print "Error: Processing file " + filename + " failed"
            sys.exit( 1 )

        f = open(filepathNoExt + ".wkb", 'wb')

        count = 0;
        for i in range(ds.GetLayerCount()):
            #print "Layer: " + str(i)

            lyr = ds.GetLayerByIndex(i)
            lyr.ResetReading()

            for feat in lyr:
                geom = feat.GetGeometryRef()
                if geom == None:
                    continue

                count = count + 1

                geom.Transform(transform)

                #print geom.ExportToWkt()

                wkb = geom.ExportToWkb()
                f.write(wkb)

            if verbose:
                print "Exported file " + filename + " with " + str(count) + " geometry objects"

        f.close()
        ds = None

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Export .shp file[s] to .wkb file[s]")

    parser.add_argument("filename", metavar="file",
                      help="export .shp file to .wkb file")
    parser.add_argument("-d", "--dir",
                      action="store_true", dest="dirname", default=False,
                      help="export all files in directory")
    parser.add_argument("-q", "--quiet",
                      action="store_false", dest="verbose", default=True,
                      help="don't print status messages to stdout")

    namespace, extra = parser.parse_known_args()

    if namespace.dirname:
        SHPExporter.export_dir(namespace.filename, namespace.verbose)
    else:
        SHPExporter.export_file("./", namespace.filename, namespace.verbose)