# Opal (run Ruby in your slides) Plugin for reveal.js

Provides for runnable code blocks in your reveal.js slide show. Also allows
for irb-like behavior, as well as the preservation of state across slides,
so that you can define a class in one slide and use it in a subsequent slide.

## Installation

1.  Move the `opal/` directory into your `reveal.js` `plugin/` directory.

2.  At the end of your dependencies list, add

        { src: 'plugin/opal/opal.min.js', async: true, },
        { src: 'plugin/opal/opal-parser.min.js', async: true },
        { src: 'plugin/opal/opal-plugin-setup.min.js', async: true }

3.  To indicate a runnable code block, ensure that the class `ruby` is
    given for the `code` tag. Additionally, provide the `opal` tag.

    Note that you will probably need to left-justify your code blocks
    in your HTML.

    Example:

        <section>
          <h2>Runnable Code</h2>
          <pre><code ruby data-trim contenteditable opal class="ruby">
        (1..10).each do |i|
          puts i
        end
          </code></pre>
        </section>

4.  For irb-like behavior, where each line is evaluated separately, and
    the evaluation of the line is shown after a `# =>` comment, use the
    `opal-irb` tag. Example:

        <section>
          <h2>irb-like behavior</h2>
          <pre><code data-trim contenteditable opal-irb class="ruby">
        [1, 2, 3].map { |e| e * 2 }
        0xff
        1_000_000
          </code></pre>
        </section>

5.  The "state" of the workspace is preserved across slides. So if you
    define a class or instance variable in one slide, such classes and
    instance variables will be preserved in subsequent slides. Once the
    state has been altered, you will see "(dirty)" after the `new workspace`
    button. To clear out the state (i.e., restart Opal), click `new workspace`.

6.  For an example of all of the above, you can use the `example-2.6.2.html`
    slide show supplied here. Don't forget to put the `opal` directory into the
    `reveal.js` `plugin` directory.
