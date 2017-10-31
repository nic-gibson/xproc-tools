<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:ccproc="http://www.corbas.co.uk/ns/xproc/steps"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
  name="directory-source" type="ccproc:directory-source">
  
  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
    <p>Use a directory as a source. We are wrapping an optionally recursive directory lister to 
      load all documents in the listing. Failure to parse can be either ignored or cause an exception, depending
      on the setting of the <code>fail-on-error</code> attribute.</p>
  </p:documentation>
  
  <p:output port="result" primary="true" sequence="true">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>The sequence of documents loaded from the input directory tree</p>
    </p:documentation>
    <p:pipe port="result" step="choose-load-docs"/>
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
  
  <p:option name="fail-on-error" select="'true'">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>If this option is set to <code>true</code> (the default), then an exception
      will be raised when a loaded document cannot be parsed. If this option is set to 
      false, a message will be written and the document dropped from the output list.</p>
    </p:documentation>
  </p:option>
  
  <p:import href="http://xml.corbas.co.uk/xml/xproc-tools/recursive-directory-list.xpl"/>
  
  <p:try name="try-listing">
    
    <p:group>
      
      <p:output port="result">
        <p:pipe port="result" step="process-directory"/>
      </p:output>
      
      <p:output port="report">
        <p:empty/>
      </p:output>
      
      <ccproc:recursive-directory-list name="process-directory" resolve="true">
        <p:with-option name="include-filter" select="$include-filter"/>
        <p:with-option name="exclude-filter" select="$exclude-filter"/>
        <p:with-option name="match-path" select="$match-path"/>
        <p:with-option name="depth" select="$depth"/>
        <p:with-option name="path" select="resolve-uri($path)"/>    
      </ccproc:recursive-directory-list>     
      
    </p:group>
    
    <p:catch>
    
      <p:output port="result">
        <p:empty/>
      </p:output>
      
      <p:output port="report">
        <p:pipe port="result" step="listing-identity"/>
      </p:output>
      
      <p:identity name="listing-identity">
        <p:input port="source">
          <p:inline><c:result/></p:inline>
        </p:input>
      </p:identity>
      
    </p:catch>    
    
  </p:try>
  
  <p:count name="count-dir-errors">
    <p:input port="source">
      <p:pipe port="report" step="try-listing"/>
    </p:input>
  </p:count>
  
  <p:choose name="choose-load-docs">
    
    <p:when test="lower-case($fail-on-error) = 'true' and not(/c:result = 0)">
      
      <p:xpath-context>
        <p:pipe port="result" step="count-dir-errors"/>
      </p:xpath-context>
      
      <p:output port="result" sequence="true">
        <p:pipe port="result" step="re-process-directory"/>
      </p:output>
      
      <!-- reraise the error -->
      <ccproc:recursive-directory-list name="re-process-directory" resolve="true">
        <p:with-option name="include-filter" select="$include-filter"/>
        <p:with-option name="exclude-filter" select="$exclude-filter"/>
        <p:with-option name="match-path" select="$match-path"/>
        <p:with-option name="depth" select="$depth"/>
        <p:with-option name="path" select="resolve-uri($path)"/>    
      </ccproc:recursive-directory-list> 
      
    </p:when>
    
    <p:otherwise>
      
      <p:output port="result"  sequence="true">
        <p:pipe port="result" step="iterate-directory-results"/>
      </p:output>
      
      <p:for-each name="iterate-directory-results">
        
        <p:output port="result">
          <p:pipe port="result" step="did-it-load"/>
        </p:output>
        
        <p:iteration-source select="//c:file">
          <p:pipe port="result" step="try-listing"/>
        </p:iteration-source>
        
        <p:try name="try-load">
          
          <p:group>
            
            <p:output port="result" primary="true" sequence="true">
              <p:pipe step="load-doc" port="result"/>
            </p:output>
            
            <!-- dummy to indicate no error -->
            <p:output port="report">
              <p:empty/>
            </p:output>        
            
            <p:load name="load-doc" dtd-validate="false">
              <p:with-option name="href" select="/c:file/@uri"/>
            </p:load>
            
          </p:group>
          
          <p:catch name="catch-load">
            
            <p:output port="result" primary="true" sequence="true">
              <p:empty/>
            </p:output>
            
            <!-- We have to do *something* in a catch, so let's copy the errors -->
            <p:output port="report">
              <p:pipe port="result" step="copy-errors"/>
            </p:output>
            
            <p:identity name="copy-errors">
              <p:input port="source">
                <p:pipe port="error" step="catch-load"/>
              </p:input>
            </p:identity>
            
          </p:catch>
          
        </p:try>
        
        <p:count name="count-load-errors">
          <p:input port="source">
            <p:pipe port="report" step="try-load"/>
          </p:input>
        </p:count>
        
        <p:choose name="did-it-load">
          
          <!-- error loading the document and we want -->
          <p:when test="lower-case($fail-on-error) = 'true' and not(/c:result = 0)">
            
            <p:xpath-context>
              <p:pipe port="result" step="count-load-errors"/>
            </p:xpath-context>
            
            <p:output port="result">
              <p:empty/>
            </p:output>
            
            <!-- do it again and let the error go -->
            <p:load name="load-doc" dtd-validate="false">
              <p:with-option name="href" select="/c:file/@uri">
                <p:pipe port="current" step="iterate-directory-results"/>
              </p:with-option>
            </p:load>
            
            <p:sink/>
            
          </p:when>
          
          <p:when test="not(/c:result = 0)">
            
            <p:output port="result">
              <p:pipe port="result" step="no-result"/>
            </p:output>
            
            <p:identity name="no-result">
              <p:input port="source">
                <p:empty/>
              </p:input>
            </p:identity>
            
          </p:when>
          
          <p:otherwise>
            
            <p:output port="result">
              <p:pipe port="result" step="good-result"/>
            </p:output>
            
            <p:identity name="good-result">
              <p:input port="source">
                <p:pipe port="result" step="try-load"/>
              </p:input>
            </p:identity>
            
          </p:otherwise>
          
        </p:choose>
        
      </p:for-each>  
      
    </p:otherwise>
    
  </p:choose>
 
  

  
</p:declare-step>