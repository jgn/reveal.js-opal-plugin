class OpalHandler
  constructor: ->
    # NOTE: If you want to tailor the styling
    # @_injectStyles()
    @_setupOpalRun()
    @_setupOpalIrb()

  _styles:
    """
      button.opal-button {
        background: #ECECEC;
        border-radius: 15px;
        font-family: arial;
        font-weight: bold;
        color: #7f7f7f;
        text-decoration: none;
        text-shadow: 0px 1px 0px #fff;
        border: 1px solid #a7a7a7;
        margin: 0px auto;
        margin-top: 5px;
        box-shadow: 0px 2px 1px white inset, 0px -2px 8px white, 0px 2px 5px rgba(0, 0, 0, 0.1), 0px 8px 10px rgba(0, 0, 0, 0.1);
        -webkit-transition: box-shadow 0.5s;
      }
      button.opal-button:hover {
        box-shadow: 0px 2px 1px white inset, 0px -2px 20px white, 0px 2px 5px rgba(0, 0, 0, 0.1), 0px 8px 10px rgba(0, 0, 0, 0.1);
      }
      button.opal-button:active {
        box-shadow: 0px 1px 2px rgba(0, 0, 0, 0.5) inset, 0px -2px 20px white, 0px 1px 5px rgba(0, 0, 0, 0.1), 0px 2px 10px rgba(0, 0, 0, 0.1);
        background: -webkit-linear-gradient(top, #d1d1d1 0%,#ECECEC 100%);
      }
    """

  _runHTML:
    """
      <pre><code class="ruby" style="height: 5em;"></code></pre>
      <div style="width: 90%; margin-left: auto; margin-right: auto; font-size: 0.4em; font-family: arial; font-weight: normal; color: #7f7f7f;">
        <div style="float: left;">
          <button class="opal-button opal-clear-workspace">New workspace</button> <span class="opal-workspace-dirty" style="visibility: hidden;">(dirty)</span>
        </div>
        <div style="float: right;">
          <button class="opal-button opal-clear">Clear output</button>
          <button class="opal-button opal-run">Run</button>
        </div>
     </div>
    """

  _irbHTML:
    """
      <button class="opal-button opal-irb">irb</button>
    """

  _irbCSS: "text-align: right; width: 90%; margin-left: auto; margin-right: auto;"

  _rubyPre:
    """
      if $opal_environment_exists.nil?
        class Workspace
          def self.instance
            @workspace ||= Object.new
          end

          def self.clear
            Object.clear
            @workspace = Object.new
          end
        end

        module Redirect
          def print(s)
            (@buffer ||= []) << s.to_s
          end
          def puts(s)
            print s
            print "\n"
          end

          def out
            return "" unless @buffer
            ret = @buffer.join
            @buffer.clear
            ret
          end
        end

        $stdout.extend(Redirect)

        class Object
          def self.top_level_classes
            @top_level_classes ||= []
          end

          def self.clear
            top_level_classes.each do |c|
              Object.send(:remove_const, c)
            end
            top_level_classes.clear
          end

          def self.inherited(c)
            top_level_classes << c unless c.to_s.include?('::')
          end
        end

        $opal_environment_exists = true
      end

      begin
        Workspace.instance.instance_eval do

    """

  _rubyPost:
    """

        end
      rescue StandardError => e
        puts e.message
      end

      $stdout.out
    """

   _setDirty: (bool) ->
    element.style.visibility = (if bool then 'visible' else 'hidden') for element in document.querySelectorAll 'span.opal-workspace-dirty'

   _evaluate: (code) ->
    output = Opal.Opal.$eval(@_rubyPre + code + @_rubyPost)
    @_setDirty(true)
    output

  _clearWorkspace: ->
    Opal.Opal.$eval(@_rubyPre + "Workspace.clear" + @_rubyPost)
    @_setDirty(false)

  _removeComment: (line) ->
      pound = line.lastIndexOf '  #'
      line = line.substring(0, pound) if pound != -1
      line.replace(/\s+$/g, '')

  _removeComments: (code) ->
    (@_removeComment(line) for line in code.split('\n')).join('\n')

  _padding: (n, pad) ->
    pad ?= " "
    s = ""
    s = s + pad while n-- > 0
    s

  _irbifyLine: (line, lengthLongest) ->
    lengthLongest ?= 0
    line + @_padding(lengthLongest - line.length) + "  # =>  " + Opal.Opal.$eval("(" + line + ").inspect")

  _irbify: (code) ->
    lines = code.split('\n')
    lengthLongest = Math.max (lines.map (line) -> line.length)...
    (@_irbifyLine(line, lengthLongest) for line in lines).join('\n')

  _unFocus: ->
    document.activeElement.blur()
    document.body.focus()


  _attachOpalRun: (element) ->
    appendAt = element.parentNode.parentNode
    div = document.createElement 'div'
    div.innerHTML = @_runHTML
    runButton = div.querySelector 'button.opal-run'
    clearButton = div.querySelector 'button.opal-clear'
    clearWorkspaceButton = div.querySelector 'button.opal-clear-workspace'
    runButton.addEventListener 'click', (e) =>
      button = e.currentTarget
      code = button.parentNode.parentNode.parentNode.parentNode.querySelector('code[opal]').textContent
      output = button.parentNode.parentNode.parentNode.querySelector 'code'
      output.innerHTML = @_evaluate code
      @_unFocus()
    clearButton.addEventListener 'click', (e) =>
      button = e.currentTarget
      output = button.parentNode.parentNode.parentNode.querySelector 'code'
      output.innerHTML = ''
      @_unFocus()
    clearWorkspaceButton.addEventListener 'click', (e) =>
      button = e.currentTarget
      @_clearWorkspace()
      @_unFocus()
    appendAt.appendChild div

  _attachOpalIrb: (element) ->
    appendAt = element.parentNode.parentNode
    div = document.createElement 'div'
    div.style.cssText = @_irbCSS
    div.innerHTML = @_irbHTML
    irbButton = div.querySelector 'button.opal-irb'
    irbButton.addEventListener 'click', (e) =>
      button = e.currentTarget
      # This button.parentNode.parentNode should be a little more specific;
      # can pick up code in a bullet list preceding the runnable code
      codeElement = button.parentNode.parentNode.querySelector('code.ruby')
      code = codeElement.textContent
      noComments = @_removeComments(code)
      irbed = @_irbify(noComments)
      button.parentNode.parentNode.querySelector('code.ruby').innerHTML = irbed
      @_unFocus()
    appendAt.appendChild div

  _injectStyles: ->
    style = document.createElement 'style'
    style.appendChild(document.createTextNode(@_styles))
    document.head.appendChild(style)

  _setupOpalRun: ->
    @_attachOpalRun(element) for element in document.querySelectorAll '[opal]'

  _setupOpalIrb: ->
    @_attachOpalIrb(element) for element in document.querySelectorAll '[opal-irb]'

new OpalHandler
