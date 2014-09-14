<p:library version="1.0" xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:pkg="http://expath.org/ns/pkg"
	pkg:import-uri="http://www.corbas/co.uk/xproc-tools/threaded-xslt"
	xmlns:p="http://www.w3.org/ns/xproc" xmlns:ccproc="http://www.corbas.co.uk/ns/xproc/steps">

	<p:documentation> This program and accompanying files are copyright 2008, 2009, 20011, 2012,
		2013 Corbas Consulting Ltd. This program is free software: you can redistribute it and/or
		modify it under the terms of the GNU General Public License as published by the Free
		Software Foundation, either version 3 of the License, or (at your option) any later version.
		This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
		without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details. You should have received a copy of the
		GNU General Public License along with this program. If not, see
		http://www.gnu.org/licenses/. If your organisation or company are a customer or client of
		Corbas Consulting Ltd you may be able to use and/or distribute this software under a
		different license. If you are not aware of any such agreement and wish to agree other
		license terms you must contact Corbas Consulting Ltd by email at corbas@corbas.co.uk. </p:documentation>

	<p:declare-step name="threaded-xslt-secondary" type="ccproc:threaded-xslt-secondary"
		exclude-inline-prefixes="#all">

		<p:documentation>
			<p xmlns="http:/wwww.w3.org/1999/xhtml">This step takes a sequence of transformation
				elements and executes them recursively applying the each stylesheet to the result of
				the previous stylesheet. The final result is the result of threading the input
				document through each of the stylesheets in turn.</p>
			<p xmlns="http:/wwww.w3.org/1999/xhtml">If secondary outputs are generated, the result
				of this pipeline will be a sequence of result documents. At each stage of the
				pipeline a sequence is created consisting of the primary and secondary outputs of
				the xslt step. This is then iterated over and recursed through.</p>
		</p:documentation>

		<p:input port="source" sequence="true" primary="true">
			<p:documentation>
				<p xmlns="http://www.w3.org/1999/xhtml">The primary input for the step is the
					document to be transformed.</p>
			</p:documentation>
		</p:input>

		<p:input port="stylesheets" sequence="true">
			<p:documentation>
				<p xmlns="http://www.w3.org/1999/xhtml">The secondary input port for the step
					contains the sequence of xslt stylesheets (already loaded) to be executed.</p>
			</p:documentation>
		</p:input>

		<p:input port="parameters" kind="parameter" primary="true">
			<p:documentation>
				<p xmlns="http:/www.w3.org/1999/xhtml">The parameters to be passed to the p:xslt
					steps.</p>
			</p:documentation>
		</p:input>

		<p:output port="result" primary="true" sequence="true">
			<p:documentation>
				<p xmlns="http://www.w3.org/1999/xhtml">The output of the step is the transformed
					document.</p>
			</p:documentation>
		</p:output>


		<!-- Split of the first transformation from the sequence -->
		<p:split-sequence name="split-stylesheets" initial-only="true" test="position()=1">
			<p:input port="source">
				<p:pipe port="stylesheets" step="threaded-xslt"/>
			</p:input>
		</p:split-sequence>

		<!-- How many of these are left? We actually only care to know  if there are *any* hence the limit. -->
		<p:count name="count-remaining-transformations" limit="1">
			<p:input port="source">
				<p:pipe port="not-matched" step="split-stylesheets"/>
			</p:input>
		</p:count>

		<!-- Ignore the result for now -->
		<p:sink/>

		<!-- Make the step input the current primary -->
		<p:identity name="force-current-primary">
			<p:input port="source">
				<p:pipe port="source" step="threaded-xslt-secondary"/>
			</p:input>
		</p:identity>

		<p:for-each name="iterate-over-input">

			<p:output port="result" primary="true" sequence="true"/>
			<p:output port="secondary" primary="false" sequence="true">
				<p:pipe port="secondary" step="run-single-xslt"/>
			</p:output>

			<p:xslt name="run-single-xslt">
				<p:input port="stylesheet">
					<p:pipe port="matched" step="split-stylesheets"/>
				</p:input>
			</p:xslt>

		</p:for-each>

		<p:identity name="gather-results">
			<p:input port="source">
				<p:pipe port="result" step="iterate-over-input"/>
				<p:pipe port="secondary" step="iterate-over-input"/>
			</p:input>
		</p:identity>


		<!-- If there are any remaining stylesheets recurse. The primary
    	input is the result of our XSLT and the remaining
    	sequence from split-transformations above will be the 
    	transformation sequence 
   		-->
		<p:choose name="determine-recursion">

			<p:xpath-context>
				<p:pipe port="result" step="count-remaining-transformations"/>
			</p:xpath-context>



			<!-- If we have any transformations remaining recurse -->
			<p:when test="number(c:result)>0">

				<ccproc:threaded-xslt-secondary name="continue-recursion">

					<p:input port="stylesheets">
						<p:pipe port="not-matched" step="split-stylesheets"/>
					</p:input>

					<p:input port="source">
						<p:pipe port="result" step="gather-results"/>
					</p:input>

				</ccproc:threaded-xslt-secondary>

			</p:when>

			<!-- Otherwise, pass the output of our transformation back as the result -->
			<p:otherwise>

				<p:identity name="terminate-recursion">
					<p:input port="source">
						<p:pipe port="result" step="gather-results"/>
					</p:input>
				</p:identity>

			</p:otherwise>

		</p:choose>

	</p:declare-step>


	<p:declare-step name="threaded-xslt" type="ccproc:threaded-xslt" exclude-inline-prefixes="#all">

		<p:documentation>
			<p xmlns="http:/wwww.w3.org/1999/xhtml">This step takes a sequence of transformation
				elements and executes them recursively applying the each stylesheet to the result of
				the previous stylesheet. The final result is the result of threading the input
				document through each of the stylesheets in turn.</p>
			<p xmlns="http:/wwww.w3.org/1999/xhtml">Secondary documents are ignored.</p>
		</p:documentation>

		<p:input port="source" sequence="false" primary="true">
			<p:documentation>
				<p xmlns="http://www.w3.org/1999/xhtml">The primary input for the step is the
					document to be transformed.</p>
			</p:documentation>
		</p:input>

		<p:input port="stylesheets" sequence="true">
			<p:documentation>
				<p xmlns="http://www.w3.org/1999/xhtml">The secondary input port for the step
					contains the sequence of xslt stylesheets (already loaded) to be executed.</p>
			</p:documentation>
		</p:input>

		<p:input port="parameters" kind="parameter" primary="true">
			<p:documentation>
				<p xmlns="http:/www.w3.org/1999/xhtml">The parameters to be passed to the p:xslt
					steps.</p>
			</p:documentation>
		</p:input>

		<p:output port="result" primary="true" sequence="true">
			<p:documentation>
				<p xmlns="http://www.w3.org/1999/xhtml">The output of the step is the transformed
					document.</p>
			</p:documentation>
		</p:output>


		<!-- Split of the first transformation from the sequence -->
		<p:split-sequence name="split-stylesheets" initial-only="true" test="position()=1">
			<p:input port="source">
				<p:pipe port="stylesheets" step="threaded-xslt"/>
			</p:input>
		</p:split-sequence>

		<!-- How many of these are left? We actually only care to know  if there are *any* hence the limit. -->
		<p:count name="count-remaining-transformations" limit="1">
			<p:input port="source">
				<p:pipe port="not-matched" step="split-stylesheets"/>
			</p:input>
		</p:count>

		<!-- Ignore the result for now -->
		<p:sink/>

		<!-- Make the step input the current primary -->
		<p:identity name="force-current-primary">
			<p:input port="source">
				<p:pipe port="source" step="threaded-xslt"/>
			</p:input>
		</p:identity>

		<p:xslt name="run-single-xslt">
			<p:input port="stylesheet">
				<p:pipe port="matched" step="split-stylesheets"/>
			</p:input>
		</p:xslt>


		<!-- If there are any remaining stylesheets recurse. The primary
    	input is the result of our XSLT and the remaining
    	sequence from split-transformations above will be the 
    	transformation sequence 
   		-->
		<p:choose name="determine-recursion">

			<p:xpath-context>
				<p:pipe port="result" step="count-remaining-transformations"/>
			</p:xpath-context>


			<!-- If we have any transformations remaining recurse -->
			<p:when test="number(c:result)>0">

				<ccproc:threaded-xslt name="continue-recursion">

					<p:input port="stylesheets">
						<p:pipe port="not-matched" step="split-stylesheets"/>
					</p:input>

					<p:input port="source">
						<p:pipe port="result" step="run-single-xslt"/>
					</p:input>

				</ccproc:threaded-xslt>

			</p:when>

			<!-- Otherwise, pass the output of our transformation back as the result -->
			<p:otherwise>

				<p:identity name="terminate-recursion">
					<p:input port="source">
						<p:pipe port="result" step="run-single-xslt"/>
					</p:input>
				</p:identity>

			</p:otherwise>

		</p:choose>

	</p:declare-step>






</p:library>
