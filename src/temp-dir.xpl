<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:pos="http://exproc.org/proposed/steps/os"
	xmlns:ccproc="http://www.corbas.co.uk/ns/xproc/steps"
	xmlns:pxf="http://exproc.org/proposed/steps/file"
    xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
	>
	
	<p:documentation>
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			
			<p>This program and accompanying files are copyright 2012, 2013 Corbas Consulting Ltd.</p>
			
			<p>This program is free software: you can redistribute it and/or modify
			it under the terms of the GNU General Public License as published by
			the Free Software Foundation, either version 3 of the License, or
			(at your option) any later version.</p>
			
			<p>This program is distributed in the hope that it will be useful,
			but WITHOUT ANY WARRANTY; without even the implied warranty of
			MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
			GNU General Public License for more details.</p>
			
			<p>You should have received a copy of the GNU General Public License
			along with this program.  If not, see http://www.gnu.org/licenses/.</p>
			
			<p>If your organisation or company are a customer or client of Corbas Consulting Ltd you may
			be able to use and/or distribute this software under a different license. If you are
			not aware of any such agreement and wish to agree other license terms you must
			contact Corbas Consulting Ltd by email at corbas@corbas.co.uk.</p>
			
		</p:documentation>
		
	</p:documentation>
	
	<p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
	
   
   <p:declare-step name='temp-dir' type="ccproc:temp-dir">
   		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
   			<p>Returns the first temporary directory name found
   			in the environment. Searches 'TMPDIR', 'TMP' and the
   			'TEMP' in that order. </p>
   		</p:documentation>
   	
   		<p:output primary="false" port="result">
   			<p:documentation xmlns="http://www.w3.org/1999/xhtml">
   				<p>Returns a <code>c:result</code> element containing the name of the temporary 
   				directory or the fallback if not found.</p>
   			</p:documentation>
   			<p:pipe port="result" step="filter-env"/>
   		</p:output>
   	
   		<p:option name="fallback" select="'.'">
   			<p:documentation xmlns="http://www.w3.org/1999/xhtml">
   				<p>The value of the fallback option is used
   				when no matching temporary directory can be found. This
   				defaults to '.' (the current directory).</p>
   			</p:documentation>
   		</p:option>
   	
   		<pos:env name="get-env">
   			<p:documentation>
   				<p>Get the environment as a list of c:env elements. See <a href="http://exproc.org/proposed/steps/os.html#env">EXProc Proposed OS Utilities</a>.</p>
   			</p:documentation>
   		</pos:env>
   	
		<p:xslt name="filter-env">
			<p:documentation xmlns="http://www.w3.org/1999/xhtml">
				<p>Filter the results of the environment listing above
				and return c:result containing the name of a temporary directory from the environment or a fallback
				if not found.</p>
			</p:documentation>
			<p:input port="source">
				<p:pipe port="result" step="get-env"/>
			</p:input>
			<p:input port="stylesheet">
				<p:inline>
					<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
						<xsl:param name="fallback-path"/>
						<!-- take first matching node -->
						<xsl:variable name="env" select="//c:env[@name=('TMPDIR', 'tmpdir', 'TMP', 'tmp', 'TEMP', 'temp')][1]"/>
						<xsl:template match="c:result">
							<c:result><xsl:value-of select="if (exists($env)) then $env/@value else $fallback-path"/></c:result>
						</xsl:template>
					</xsl:stylesheet>
				</p:inline>
			</p:input>
			<p:with-param name="fallback-path" select="$fallback"/>
		</p:xslt>
   	
   	
   </p:declare-step>
	
	<p:declare-step name="temp-file" type="ccproc:temp-file">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>Uses ccproc:temp-dir and pxf:tempfile to create a temporary file in the system temp directory. All
				options are as documented in <a href="http://exproc.org/proposed/steps/fileutils.html#tempfile">EXProc Proposed File Utilities</a>.</p>
		</p:documentation>
		
		<p:output port="result" primary="false">
			<p:pipe port="result" step="base-temp-file"/>
		</p:output>
		
		<p:option name="prefix"/>                  				<!-- as documented in http://exproc.org/proposed/steps/fileutils.html#tempfile -->
		<p:option name="suffix"/>                  				<!-- as documented in http://exproc.org/proposed/steps/fileutils.html#tempfile -->
		<p:option name="delete-on-exit" select="'false'"/>     <!-- as documented in http://exproc.org/proposed/steps/fileutils.html#tempfile -->
		<p:option name="fail-on-error" select="'true'"/>       <!-- as documented in http://exproc.org/proposed/steps/fileutils.html#tempfile -->
		
		<ccproc:temp-dir name="get-temp"/>
		<p:identity name="make-temp-primary">
			<p:input port="source">
				<p:pipe port="result" step="get-temp"/>
			</p:input>
		</p:identity>
		
		<!-- NB - this is a touch painful because we need to omit prefix and suffix from the options for
			pxf:tempifle when they're not supplied to this step. Defining substep output is is also slightly
			painful as the result port of pxf:tempfile is (correctly) not primary. -->
		<p:choose name="base-temp-file">
			
			<p:when test="p:value-available('prefix') and p:value-available('suffix')">
				<p:output port="result">
					<p:pipe port="result" step="base-temp-file-all"/>
				</p:output>
				<pxf:tempfile name="base-temp-file-all">
					<p:with-option name="prefix" select="$prefix"/>
					<p:with-option name="suffix" select="$suffix"/>
					<p:with-option name="delete-on-exit" select="$delete-on-exit"/>
					<p:with-option name="fail-on-error" select="$fail-on-error"/>
					<p:with-option name="href" select="/c:result/text()"/>
				</pxf:tempfile>						
			</p:when>
			
			<p:when test="p:value-available('prefix')">
				<p:output port="result">
					<p:pipe port="result" step="base-temp-file-prefix"/>
				</p:output>
				<pxf:tempfile name="base-temp-file-prefix">
					<p:with-option name="prefix" select="$prefix"/>
					<p:with-option name="delete-on-exit" select="$delete-on-exit"/>
					<p:with-option name="fail-on-error" select="$fail-on-error"/>
					<p:with-option name="href" select="/c:result/text()"/>
				</pxf:tempfile>	
			</p:when>
			
			<p:when test="p:value-available('suffix')">
				<p:output port="result">
					<p:pipe port="result" step="base-temp-file-suffix"/>
				</p:output>
				<pxf:tempfile name="base-temp-file-suffix">
					<p:with-option name="suffix" select="$suffix"/>
					<p:with-option name="delete-on-exit" select="$delete-on-exit"/>
					<p:with-option name="fail-on-error" select="$fail-on-error"/>
					<p:with-option name="href" select="/c:result/text()"/>
				</pxf:tempfile>	
			</p:when>
			
			<p:otherwise>
				<p:output port="result">
					<p:pipe port="result" step="base-temp-file-none"/>
				</p:output>
				<pxf:tempfile name="base-temp-file-none">
					<p:with-option name="delete-on-exit" select="$delete-on-exit"/>
					<p:with-option name="fail-on-error" select="$fail-on-error"/>
					<p:with-option name="href" select="/c:result/text()"/>
				</pxf:tempfile>				
			</p:otherwise>
			
		</p:choose>
		
	</p:declare-step>
	

	
    
</p:library>