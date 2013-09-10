<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
  <xsl:key name="properties" match="property" use="@name"/>
  <xsl:template match="/">
    <html>
      <body>
        <ul>
          <!--<li>-->
<!--delete from IdealAEnt;</li>-->
          <!--<li>-->
<!--delete from IdealReln;</li>-->
          <!--<li>-->
<!--delete from AEntType;</li>-->
          <!--<li>-->
<!--delete from RelnType;</li>-->
          <!--<li>-->
<!--delete from Attributekey;-->
          <!--</li>-->
          <xsl:for-each select="//property[count(. | key('properties', @name)[1]) = 1]">
            <li>
INSERT INTO AttributeKey(AttributeID, AttributeType, AttributeName, AttributeDescription)
VALUES('<xsl:value-of select="substring(generate-id(key('properties',@name)),4)"/>', '<xsl:value-of select="@type"/>', '<xsl:value-of select="@name"/>', '<xsl:value-of select="normalize-space(description)"/>');
            </li>
            <ul>
              <xsl:for-each select="lookup/term">
                <li>
INSERT INTO Vocabulary (vocabId, attributeid, vocabname <xsl:if test="@pictureURL != ''">, pictureURL</xsl:if>, vocabdescription)
VALUES('<xsl:value-of select="substring(generate-id(.),4)"/>', '<xsl:value-of select="substring(generate-id(key('properties',../../@name)),4)"/>', '<xsl:value-of select="normalize-space(./text())"/>' <xsl:if test="@pictureURL != ''">, '<xsl:value-of select="@pictureURL"/>'</xsl:if>, '<xsl:value-of select="normalize-space(description)"/>');
                </li>
              </xsl:for-each>
            </ul>
          </xsl:for-each>

          <xsl:for-each select="dataSchema/RelationshipElement">
            <li>
INSERT INTO RelnType(RelnTypeID, RelnTypeName, RelnTypeDescription, RelnTypeCategory, Parent, Child)
VALUES('<xsl:value-of select="substring(generate-id(.),4)"/>', '<xsl:value-of select="@name"/>', '<xsl:value-of select="normalize-space(description)"/>', '<xsl:value-of select="@type"/>', '<xsl:value-of select="normalize-space(parent)"/>', '<xsl:value-of select="normalize-space(child)"/>');
            </li>
            <ul>
              <xsl:for-each select="property">
                <li>
INSERT INTO IdealReln(RelnTypeID, AttributeID, MinCardinality, MaxCardinality, isIdentifier)
VALUES('<xsl:value-of select="substring(generate-id(..),4)"/>', '<xsl:value-of select="substring(generate-id(key('properties',@name)),4)"/>', '<xsl:value-of select="@minCardinality"/>', '<xsl:value-of select="@maxCardinality"/>', '<xsl:value-of select="@isIdentifier"/>');
                </li>
              </xsl:for-each>
            </ul>
          </xsl:for-each>

          <xsl:for-each select="dataSchema/ArchaeologicalElement">
            <li>
INSERT INTO AEntType (AEntTypeID, AEntTypeName, AEntTypeDescription)
VALUES ('<xsl:value-of select="substring(generate-id(.),4)"/>', '<xsl:value-of select="@type"/>', '<xsl:value-of select="normalize-space(description)"/>');
            </li>
            <ul>
              <xsl:for-each select="property">
                <li>
INSERT INTO IdealAEnt(AEntTypeID, AttributeID, MinCardinality, MaxCardinality, isIdentifier)
VALUES('<xsl:value-of select="substring(generate-id(..),4)"/>', '<xsl:value-of select="substring(generate-id(key('properties',@name)),4)"/>', '<xsl:value-of select="@minCardinality"/>', '<xsl:value-of select="@maxCardinality"/>', '<xsl:value-of select="@isIdentifier"/>');
                </li>
              </xsl:for-each>
            </ul>
          </xsl:for-each>
        </ul>

      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>

