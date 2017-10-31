<p:declare-step type="ccproc:recursive-directory-list" 
  xmlns:p="http://www.w3.org/ns/xproc"
	version="1.0" xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:cfn="http:/www.corbas.co.uk/ns/xslt/functions"
	xmlns:pos="http://exproc.org/proposed/steps/os"
	xmlns:ccproc="http://www.corbas.co.uk/ns/xproc/steps">

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
		<p>Recursively explore directory listings. The include and exclude filters are only applied
			to file names and not to directories. The filters are implemented as regular expressions
			not glob patterns. This seems more useful than the standard approach. We've implemented
			this by handling the pattern matches in xslt rather than in the
				<code>p:directory-list</code> step. The patterns are not required to match the whole
			path name.</p>
	</p:documentation>


	<p:output port="result">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>The result of the step is a <code>c:directory</code> element as defined for the
					<code>p:directory-list</code> step. However, all child directories are processed
				and expanded as well.</p>
		</p:documentation>
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

	<p:option name="depth" select="-1">
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>The <code>depth</code> option allows the depth of recursion to be restricted. The
				depth counter is decremented by one for each recursion. If it ever drops to zero,
				recursion will stop. The default value is <strong>-1</strong> so recursion will
				never stop. At least one directory listing level will always be generated</p>
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
	

	<p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://xml.corbas.co.uk/xml/xproc-tools/directory-list.xpl"/>

	<!-- find out the directory separator -->
	<pos:info name="get-os-info"/>

	<!-- get the listing fo the top directory -->
	<ccproc:directory-list name="listing">
		<p:with-option name="path" select="$path"/>
		<p:with-option name="include-filter" select="$include-filter"/>
		<p:with-option name="exclude-filter" select="$exclude-filter"/>
		<p:with-option name="match-path" select="$match-path"/>
		<p:with-option name="resolve" select="$resolve"/>
	</ccproc:directory-list>

	<p:viewport match="/c:directory/c:directory" name="recurse-directory">
		<p:variable name="name" select="/*/@name"/>
		<p:variable name="separator" select="/c:result/@file-separator">
			<p:pipe port="result" step="get-os-info"/>
		</p:variable>
		

		<p:choose>
			
			<p:when test="$depth != 0">

				<ccproc:recursive-directory-list>
					<p:with-option name="path" select="concat($path,$separator,encode-for-uri($name))"/>
					<p:with-option name="include-filter" select="$include-filter"/>
					<p:with-option name="exclude-filter" select="$exclude-filter"/>
					<p:with-option name="match-path" select="$match-path"/>
					<p:with-option name="depth" select="$depth - 1"/>
					<p:with-option name="resolve" select="$resolve"/>
				</ccproc:recursive-directory-list>
				
			</p:when>
			
			<p:otherwise>
				<p:identity/>
			</p:otherwise>
			
		</p:choose>

	</p:viewport>

</p:declare-step>
