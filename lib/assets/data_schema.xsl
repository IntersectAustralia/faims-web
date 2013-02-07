<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

  <xsl:key name="properties" match="property" use="@name" />

  <xsl:template match="/">

          delete from IdealAEnt;
          delete from IdealReln;
          delete from AEntType;
          delete from RelnType;
          delete from attributekey;

          <xsl:for-each select="//property[count(. | key('properties', @name)[1]) = 1]">
            INSERT INTO attributeKey(AttributeID, AttributeType, AttributeName, AttributeDescription) VALUES('<xsl:value-of select="substring(generate-id(key('properties',@name)),4)"/>', '<xsl:value-of select="@type"/>','<xsl:value-of select="@name"/>','<xsl:value-of select="description"/>');
          </xsl:for-each>
          <xsl:for-each select="dataSchema/RelationshipElement">
            
              INSERT INTO RelnType(RelnTypeID, RelnTypeName, RelnTypeDescription, RelnTypeCategory, Parent, Child)
              VALUES('<xsl:value-of select="substring(generate-id(.),4)"/>', '<xsl:value-of select="@name"/>', '<xsl:value-of select="description"/>','<xsl:value-of select="@type"/>', '<xsl:value-of select="parent"/>', '<xsl:value-of select="child"/>'
              );
            
              <xsl:for-each select="property">
                  INSERT INTO IdealReln(RelnTypeID, AttributeID, MinCardinality, MaxCardinality) VALUES('<xsl:value-of select="substring(generate-id(..),4)"/>','<xsl:value-of select="substring(generate-id(key('properties',@name)),4)"/>','<xsl:value-of select="@minCardinality"/>','<xsl:value-of select="@maxCardinality"/>');
                  <xsl:for-each select="lookup/term">
                     INSERT INTO Vocabulary (vocabId, attributeid, vocabname <xsl:if test="@pictureURL != ''">, pictureURL</xsl:if>
                      ) values('<xsl:value-of select="substring(generate-id(.),4)"/>', '<xsl:value-of select="substring(generate-id(key('properties',../../@name)),4)"/>', '<xsl:value-of select="."/>' <xsl:if test="@pictureURL != ''">, '<xsl:value-of select="@pictureURL"/>'</xsl:if>); 
                  </xsl:for-each>
              </xsl:for-each>
          </xsl:for-each>

          <xsl:for-each select="dataSchema/ArchaeologicalElement">
            INSERT INTO AEntType (AEntTypeID, AEntTypeName, AEntTypeDescription) VALUES ('<xsl:value-of select="substring(generate-id(.),4)"/>','<xsl:value-of select="@type"/>', '<xsl:value-of select="description"/>');
              <xsl:for-each select="property">
                INSERT INTO IdealAEnt(AEntTypeID, AttributeID, MinCardinality, MaxCardinality) VALUES('<xsl:value-of select="substring(generate-id(..),4)"/>','<xsl:value-of select="substring(generate-id(key('properties',@name)),4)"/>','<xsl:value-of select="@minCardinality"/>','<xsl:value-of select="@maxCardinality"/>'); 
                  <xsl:for-each select="lookup/term">
                     INSERT INTO Vocabulary (vocabId, attributeid, vocabname <xsl:if test="@pictureURL != ''">, pictureURL</xsl:if>) values('<xsl:value-of select="substring(generate-id(.),4)"/>', '<xsl:value-of select="substring(generate-id(key('properties',../../@name)),4)"/>', '<xsl:value-of select="."/>'<xsl:if test="@pictureURL != ''">, '<xsl:value-of select="@pictureURL"/>'</xsl:if>); 
                  </xsl:for-each>
              </xsl:for-each>
          </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
