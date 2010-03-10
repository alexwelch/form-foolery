# Copy form.css file...
RAILS_ROOT = File.join(File.dirname(__FILE__), '../../../') unless defined? RAILS_ROOT

FileUtils.cp( 
  File.join(File.dirname(__FILE__), 'resources', 'form.css'), 
  File.join(RAILS_ROOT, 'public', 'stylesheets'),
  :verbose => true
)

FileUtils.cp(
  File.join(File.dirname(__FILE__), 'resources', 'formfoolery.js'), 
  File.join(RAILS_ROOT, 'public', 'javascripts'),
  :verbose => true
)

FileUtils.cp(
  File.join(File.dirname(__FILE__), 'resources', 'lowpro.js'), 
  File.join(RAILS_ROOT, 'public', 'javascripts'),
  :verbose => true
)

# Show the INSTALL text file
puts IO.read(File.join(File.dirname(__FILE__), 'INSTALL'))

