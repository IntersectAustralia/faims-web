<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- Edited by XMLSpy® -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/">
delete from User;
      <xsl:for-each select="dataSchema/UserElement">
<p>INSERT INTO User(UserId, Fname, Lname) VALUES('<xsl:value-of select="@userId"/>', '<xsl:value-of select="fname"/>','<xsl:value-of select="lname"/>');</p>

</xsl:for-each>

</xsl:template>
</xsl:stylesheet>

