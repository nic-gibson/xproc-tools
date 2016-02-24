<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:data="http://www.corbas.co.uk/ns/transforms/data"
	xmlns:ccproc="http://www.corbas.co.uk/ns/xproc/steps"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:c="http://www.w3.org/ns/xproc-step"
	version="1.0">	
	
	<p:declare-step type="ccproc:load-sequence-from-file" name="load-sequence-from-file">

		<p:documentation xmlns="http://wwww.w3.org/1999/xhtml">
			<p>This program and accompanying files are copyright 2008, 2009, 20011, 2012, 2013 Corbas
				Consulting Ltd.</p>
			<p>This program is free software: you can redistribute it and/or modify it under the terms of
				the GNU General Public License as published by the Free Software Foundation, either version
				3 of the License, or (at your option) any later version.</p>
			<p>This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
				without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
				See the GNU General Public License for more details.</p>
			<p>You should have received a copy of the GNU General Public License along with this program.
				If not, see http://www.gnu.org/licenses/.</p>
			<p>If your organisation or company are a customer or client of Corbas Consulting Ltd you may
				be able to use and/or distribute this software under a different license. If you are not
				aware of any such agreement and wish to agree other license terms you must contact Corbas
				Consulting Ltd by email at <a href="mailto:corbas@corbas.co.uk">corbas@corbas.co.uk</a>.</p>
		</p:documentation>

		<p:documentation  xmlns="http://wwww.w3.org/1999/xhtml">
			
			<p>Script to read an xml manifest file containing a list of files, load them and return a
				sequence of the files in the order they were contained in the input file. The input file
				should validate against <span class="filename">manifest.rng</span>. The <code
					class="attribute">href</code> attribute of each <code class="element">item</code> element
				is used to identify the files to be loaded. The file names are resolved agains the base uri
				of the manifest file (or their own base if overridden via <code class="attribute"
					>xml:base</code>. 
			</p>
			
		</p:documentation>


		<p:input port="source" primary="true">
			<p:documentation xmlns="http://www.w3.org/1999/xhtml">
				<p>The source port should provide a manifest document as described above.</p>
			</p:documentation>
		</p:input>

		<p:output port="result" primary="true" sequence="true">
			<p:documentation xmlns="http://www.w3.org/1999/xhtml">
				<p>The result port will contain a sequence of documents loaded from the list contained on
					the input port</p>
			</p:documentation>
			<p:pipe port="result" step="load-iterator"/>
		</p:output>

		<p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

	
		<p:declare-step name="process-metadata" type="ccproc:process-metadata">
			<p:documentation xmlns="http://www.w3.org/1999/xhtml">
				<p>Checks if an item from the manifest has any associated metadata and inserts it if it
					does.</p>
			</p:documentation>
			
			<p:input port="manifest-item" sequence="true">
				<p:documentation xmlns="http://www.w3.org/1999/xhtml">
					<p>The manifest items to be used a metadata source.</p>
				</p:documentation>
			</p:input>
			
			<p:input port="document">
				<p:documentation xmlns="http://www.w3.org/1999/xhtml">
					<p>The document to be annotated.</p>
				</p:documentation>
			</p:input>
			
			<p:output port="result">
				<p:documentation xmlns="http:/www.w3.org/1999/xhtml">
					<p>The annotated document</p>
				</p:documentation>
				<p:pipe port="result" step="insert-metadata"/>
			</p:output>
			
			<!-- find the metadata by filtering it -->
			<p:filter name="find-metadata" select="//data:meta">
				<p:input port="source">
					<p:pipe port="manifest-item" step="process-metadata"/>
				</p:input>
			</p:filter>
			
			<!-- recursively insert the metadata -->
			<ccproc:insert-metadata name="insert-metadata">
				<p:input port="metadata">
					<p:pipe port="result" step="find-metadata"/>
				</p:input>
				<p:input port="document">
					<p:pipe port="document" step="process-metadata"/>
				</p:input>
			</ccproc:insert-metadata>
			
			
		</p:declare-step>
		
		<p:declare-step name="insert-metadata" type="ccproc:insert-metadata">
			
			<p:documentation xmlns="http://www.w3.org/1999/xhtml">
				<p>Inserts any metadata elements defined in the manifest into the loaded (or generated)
					documents. Calls itself recursively to add each of the items. The annotations are added as
					attributes in the <strong>http://www.corbas.co.uk/ns/transforms/data</strong> namespace on
					the root element of the document.</p>
			</p:documentation>
			
			<p:input port="metadata" sequence="true">
				<p:documentation xmlns="http://www.w3.org/1999/xhtml">
					<p>The metadata items to be used as annotations on the document.</p>
				</p:documentation>
			</p:input>
			
			<p:input port="document">
				<p:documentation xmlns="http://www.w3.org/1999/xhtml">
					<p>The document to be annotated.</p>
				</p:documentation>
			</p:input>
			
			<p:output port="result">
				<p:documentation xmlns="http:/www.w3.org/1999/xhtml">
					<p>The annotated document</p>
				</p:documentation>
				<p:pipe port="result" step="metadata-actions"/>
			</p:output>
			
			<!-- How many items in the metadata sequence? -->
			<p:count name="count-metadata" limit="1">
				<p:input port="source">
					<p:pipe port="metadata" step="insert-metadata"/>
				</p:input>
			</p:count>
			
			<p:choose name="metadata-actions">
				
				<p:xpath-context>
					<p:pipe port="result" step="count-metadata"/>
				</p:xpath-context>
				
				<!-- empty list - bail -->
				<p:when test="number(c:result) = 0">
					
					<p:output port="result">
						<p:pipe port="result" step="stop-recursion"/>
					</p:output>
					
					<p:identity name="stop-recursion">
						<p:input port="source">
							<p:pipe port="document" step="insert-metadata"/>
						</p:input>
					</p:identity>
					
				</p:when>
				
				<!-- at least one -->
				<p:otherwise>
					
					<p:output port="result">
						<p:pipe port="result" step="insert-next"/>
					</p:output>
					
					
					<!-- Split of the first metadata item from the sequence -->
					<p:split-sequence name="split-metadata" initial-only="true" test="position()=1">
						<p:input port="source">
							<p:pipe port="metadata" step="insert-metadata"/>
						</p:input>
					</p:split-sequence>
					
					<!-- add the attribute -->
					<p:add-attribute attribute-namespace="http://www.corbas.co.uk/ns/transforms/meta" attribute-prefix="meta"
						name="insert-meta-item" match="/*">
						<p:with-option name="attribute-name" select="/data:meta/@name">
							<p:pipe port="matched" step="split-metadata"/>
						</p:with-option>
						<p:with-option name="attribute-value" select="/data:meta/@value">
							<p:pipe port="matched" step="split-metadata"/>
						</p:with-option>
						<p:input port="source">
							<p:pipe port="document" step="insert-metadata"/>
						</p:input>
					</p:add-attribute>
					
					<!-- recurse -->
					<ccproc:insert-metadata name="insert-next">
						<p:input port="metadata">
							<p:pipe port="not-matched" step="split-metadata"/>
						</p:input>
						<p:input port="document">
							<p:pipe port="result" step="insert-meta-item"/>
						</p:input>
					</ccproc:insert-metadata>
					
				</p:otherwise>
				
			</p:choose>
			
		</p:declare-step>

	
		<!-- Get the manifest into a simple flat format. -->
		<ccproc:normalise-manifest name="load-manifest"/>

		<!-- Loop over input and load each file in turn. 
		We don't handle errors here because the default behaviour (exit with error)
		is the desired behaviour and the error message is just fine -->
		<p:for-each name="load-iterator">

			<p:output port="result" primary="true"/>

			<p:iteration-source select="/data:manifest/*">
				<p:pipe port="result" step="load-manifest"/>
			</p:iteration-source>

			<p:choose name="load-item">

				<p:when test="/data:item">
					
					<p:output port="result">
						<p:pipe port="result" step="load-doc"></p:pipe>
					</p:output>

					<p:variable name="href" select="p:resolve-uri(/data:item/@href, p:base-uri(/data:item))"/>

					<!-- <cx:message>
					<p:with-option name="message" select="concat('item: ', $href)"/>
				</cx:message> -->

					<p:load name="load-doc">
						<p:with-option name="href" select="$href"/>
					</p:load>

				</p:when>

				<p:otherwise>
					
					<p:output port="result">
						<p:pipe port="result" step="process-item"></p:pipe>
					</p:output>

					<p:variable name="stylesheet"
						select="p:resolve-uri(/data:processed-item/@stylesheet, 
						p:base-uri(/data:processed-item))"/>
					<p:variable name="href"
						select="p:resolve-uri(/data:processed-item/data:item/@href, 
						p:base-uri(/data:processed-item/data:item))"/>

					<!--<cx:message>
					<p:with-option name="message" select="concat('stylesheet: ', $stylesheet)"/>
				</cx:message>-->

					<p:load name="load-stylesheet">
						<p:with-option name="href" select="$stylesheet"/>
					</p:load>

					<!--<cx:message>
					<p:with-option name="message" select="concat('item: ', $href)"/>
				</cx:message>-->

					<p:load name="load-data">
						<p:with-option name="href" select="$href"/>
					</p:load>

					<p:xslt name="process-item">
						<p:input port="parameters">
							<p:empty/>
						</p:input>
						<p:input port="stylesheet">
							<p:pipe port="result" step="load-stylesheet"/>
						</p:input>
						<p:input port="source">
							<p:pipe port="result" step="load-data"/>
						</p:input>
					</p:xslt>

				</p:otherwise>
			</p:choose>

			<ccproc:process-metadata name="set-meta">
				<p:input port="document">
					<p:pipe port="result" step="load-item"></p:pipe>
				</p:input>
				<p:input port="manifest-item">
					<p:pipe port="current" step="load-iterator"/>
				</p:input>
			</ccproc:process-metadata>
			

		</p:for-each>

	</p:declare-step>
	
	<p:declare-step
		name="normalise-manifest" type="ccproc:normalise-manifest">
		
		<p:documentation xmlns="http://www.w3.org/1999/xhtml">
			<p>This step pre-processes a manifest, loading imports, handling enabled/disabled nodes and
				flattening groups. Metadata is also normalised across the nodes.</p>
		</p:documentation>
		
		<p:input port="source" primary="true">
			<p:documentation xmlns="http://www.w3.org/1999/xhtml">
				<p>The document to be normalised.</p>
			</p:documentation>
		</p:input>
		
		<p:output port="result" primary="true">
			<p:documentation xmlns="http://www.w3.org/1999/xhtml">
				<p>The normalised manifest.</p>
				<p:pipe port="result" step="flatten-manifest"/>
			</p:documentation>
		</p:output>
		
		<!-- load all the imports except those that are not enabled -->
		<p:xslt version="2.0" name="process-imports">
			
			<p:input port="source">
				<p:pipe port="source" step="normalise-manifest"/>
			</p:input>
			
			<p:input port="parameters">
				<p:empty/>
			</p:input>
			
			<p:input port="stylesheet">
			  <p:document href="http://xml.corbas.co.uk/xml/xproc-tools/xslt/process-imports.xsl"/>
			</p:input>
			
		</p:xslt>
		
		<!-- strip out all content where enabled is explicitly set to false -->
		<p:xslt version="2.0" name="remove-disabled">
			
			<p:input port="source">
				<p:pipe port="result" step="process-imports"/>
			</p:input>
			
			<p:input port="parameters">
				<p:empty/>
			</p:input>
			
			<p:input port="stylesheet">
			  <p:document href="http://xml.corbas.co.uk/xml/xproc-tools/xslt/remove-disabled.xsl"/>
			</p:input>
			
		</p:xslt>
		
		<!-- cascade group metadata down -->
		<p:xslt version="2.0" name="normalise-metadata">
			
			<p:input port="source">
				<p:pipe port="result" step="remove-disabled"/>
			</p:input>
			
			<p:input port="parameters">
				<p:empty/>
			</p:input>
			
			<!-- this stylesheet merges metadata onto each item to ensure that
			the 'nearest' (lowest in the document tree) metadata element with
			a given name is assigned to the item -->
			<p:input port="stylesheet">
			  <p:document href="http://xml.corbas.co.uk/xml/xproc-tools/xslt/normalise-metadata.xsl"/>
			</p:input>
			
		</p:xslt>
		
		<!-- lose the groups and expand processed-item elements if needed. -->
		<p:xslt version="2.0" name="flatten-manifest">
			<p:input port="source">
				<p:pipe port="result" step="normalise-metadata"/>
			</p:input>
			
			<p:input port="parameters">
				<p:empty/>
			</p:input>
			
			<p:input port="stylesheet">
			  <p:document href="http://xml.corbas.co.uk/xml/xproc-tools/xslt/flatten-manifest.xsl"/>		
			</p:input>
			
		</p:xslt>		
		
		
	</p:declare-step>		
	
</p:library>




