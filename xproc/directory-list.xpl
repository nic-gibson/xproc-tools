<p:declare-step type="ccproc:directory-list" xmlns:p="http://www.w3.org/ns/xproc" version="1.0"
	xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:cx="http://xmlcalabash.com/ns/extensions"
	xmlns:cfn="http:/www.corbas.co.uk/ns/xslt/functions"
	xmlns:ccproc="http://www.corbas.co.uk/ns/xproc/steps"
	 name="directory-list" >

	<p:documentation xmlns="http://www.w3.org/1999/xhtml">
		<p>This program and accompanying files are copyright 2008, 2009, 20011, 2012, 2013 Corbas
			Consulting Ltd.</p>
		<p>This program is free software: you can redistribute it and/or modify it under the terms
			of the GNU General Public License as published by the Free Software Foundation, either
			version 3 of the License, or (at your option) any later version.</p>
		<p>This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
			without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
			PURPOSE. See the GNU General Public License for more details.</p>
		<p>You should have received a copy of the GNU General Public License along with this
			program. If not, see http://www.gnu.org/licenses/.</p>
		<p>If your organisation or company are a customer or client of Corbas Consulting Ltd you may
			be able to use and/or distribute this software under a different license. If you are not
			aware of any such agreement and wish to agree other license terms you must contact
			Corbas Consulting Ltd by email at <a href="mailto:corbas@corbas.co.uk"
				>corbas@corbas.co.uk</a>.</p>
	</p:documentation>

	<p:documentation xmlns="http://www.w3.org/1999/xhtml">
		<p>Generate directory listings. The include and exclude filters are only applied to file
			names and not to directories. The filters are implemented as regular expressions matching any
			part of the file name. This seems more useful than the standard approach. We've implemented this
			by handling the pattern matches in xslt rather than in the <code>p:directory-list</code>
			step. The patterns are not required to match the whole path name (unless desired)</p>
	</p:documentation>


	<p:output port="result">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>The result of the step is a <code>c:directory</code> element as defined for the
					<code>p:directory-list</code> step.</p>
		</p:documentation>
		<p:pipe port="result" step="filter-listing"/>
	</p:output>
	<p:option name="path" required="true">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>The path option defines the path to be searched.</p>
		</p:documentation>
	</p:option>
	<p:option name="include-filter" select="''">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>The <code>include-filter</code> option allows an option <em>regular expression</em>
				to be applied to either the file name or path name (depending on the value of
					<code>match-path</code> option). If the the match is successful, the file is
				retained unless excluded by the <code>exclude-filter</code> option.</p>
			<p>Directory names are not filtered and are always processed.</p>
		</p:documentation>
	</p:option>
	<p:option name="exclude-filter" select="''">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>The <code>exclude-filter</code> option allows an option <em>regular expression</em>
				to be applied to either the file name or path name (depending on the value of
					<code>match-path</code> option). If the the match is successful, the file is
				excluded from the results. The <code>exclude-filter</code> is applied after the
					<code>include-filter</code></p>
			<p>Directory names are not filtered and are always processed.</p>
		</p:documentation>
	</p:option>

	<p:option name="match-path" select="'false'">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>The <code>match-path</code> option determines whether or not the
					<code>include-filter</code> and <code>exclude-filter</code> options should apply
				to the whole path or just the file name. If set to <strong>true</strong> (case is
				insignificant) the file name will be combined with the path before the regular
				expressions are applied. If set to any other value then only the file name is
				tested.</p>
		</p:documentation>
	</p:option>

	<p:option name="resolve" select="'false'">
		<p:documentation  xmlns="http://www.w3.org/1999/xhtml">
			<p>The <code>resolve</code> options sets whether or not the <code>uri</code>
			attribute is created for a directory or file. If set to <strong>true</strong> then
			an additional attribute — <code>uri</code> — is set. This attribute contains
			the resolved uri for any file or directory</p>
		</p:documentation>
	</p:option>
  
<!--
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  
  <cx:message>
    <p:input port="source"><p:empty/></p:input>
    <p:with-option name="message" select="concat('Generating listing for' , $path)"/>
  </cx:message>  
-->

	<!-- get the listing fo the top directory -->
	<p:directory-list name="listing">
		<p:with-option name="path" select="$path"/>
	</p:directory-list>

	<!-- filter -->
	<p:xslt name="filter-listing">
		<p:input port="source">
			<p:pipe port="result" step="listing"/>
		</p:input>
		<p:input port="stylesheet">
			<p:inline>
				<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
					xmlns:xs="http://www.w3.org/2001/XMLSchema"
					xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
					xmlns:c="http://www.w3.org/ns/xproc-step"
					xmlns:cfn="http:/www.corbas.co.uk/ns/xslt/functions"
					exclude-result-prefixes="xs xd" version="2.0">
					<xd:doc scope="stylesheet">
						<xd:desc>
							<xd:p><xd:b>Created on:</xd:b> Jun 4, 2014</xd:p>
							<xd:p><xd:b>Author:</xd:b> nicg</xd:p>
							<xd:p><xd:b>Added resolve attribute - nicg - 14/09/2014</xd:b></xd:p>
						</xd:desc>
					</xd:doc>

					<xsl:param name="include-filter" as="xs:string"/>
					<xsl:param name="exclude-filter" as="xs:string"/>
					<xsl:param name="match-path" as="xs:string"/>
					<xsl:param name="resolve" as="xs:string"/>

					<xsl:template match="c:directory|c:other|c:file[cfn:include-file(.)]|@*|text()">
						<xsl:copy>
							<xsl:if test="lower-case($resolve) = 'true' and parent::*">
								<xsl:attribute name="uri" select="resolve-uri(@name, parent::*/@xml:base)"/>
							</xsl:if>
							<xsl:apply-templates select="@*|node()"/>
						</xsl:copy>
					</xsl:template>

					<xsl:template match="c:file"/>

					<xsl:function name="cfn:include-file" as="xs:boolean">
						<xsl:param name="node" as="element(c:file)"/>

						<!-- search whole path if match-path is set to true, else file name -->
						<xsl:variable name="search-string"
							select="if (lower-case($match-path) = 'true') 
								then concat($node/../@xml:base, $node/@name) else $node/@name"/>

						<!-- potential include if no filter or matches filter -->
						<xsl:variable name="potential-include"
							select="if ($include-filter = '') then true()
								else matches($search-string, $include-filter)"/>

						<!-- potential exclude if there is a filter and it matches -->
						<xsl:variable name="potential-exclude"
							select="if ($exclude-filter = '') then false()
								else matches($search-string, $exclude-filter)"/>

						<!-- include if potential-include and not potential-exclude -->
						<xsl:value-of select="$potential-include and not($potential-exclude)"/>

					</xsl:function>

				</xsl:stylesheet>
			</p:inline>
		</p:input>
		<p:with-param name="include-filter" select="$include-filter"/>
		<p:with-param name="exclude-filter"	select="$exclude-filter"/>
		<p:with-param name="match-path" select="$match-path"/>
		<p:with-param name="resolve" select="if (lower-case($resolve) eq 'true') then 'true' else 'false'"/>
		
	</p:xslt>



</p:declare-step>
