#! /usr/bin/python

import sys
import os
import argparse
import ogr
import osr

class SHPDump:

    @staticmethod
    def dump_file(dirname, filename):

        filepath = dirname + filename

        # dump file
        ds = ogr.Open(filepath)
        if ds is None:
            print "Error: Processing file " + filename + " failed"
            sys.exit( 1 )

        lyr = ds.GetLayerByIndex(0)
        print lyr.GetName()
        print lyr.GetFeatureCount()

        count = 0;
        for i in range(ds.GetLayerCount()):
            print "Layer: " + str(i)

            lyr = ds.GetLayerByIndex(i)
            lyr.ResetReading()

            for feat in lyr:
                geom = feat.GetGeometryRef()
                if geom == None:
                    print "Geom " + str(count) + " has no geometry"
                    continue

                #print "Geom " + str(count) + " is ok"

                count = count + 1

        ds = None

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Export .shp file[s] to .wkb file[s]")

    parser.add_argument("filename", metavar="file",
                      help="dump .shp file")

    namespace, extra = parser.parse_known_args()

    SHPDump.dump_file("./", namespace.filename)