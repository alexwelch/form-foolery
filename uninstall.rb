# Remove form.css file...
RAILS_ROOT = File.join(File.dirname(__FILE__), '../../../') unless defined? RAILS_ROOT

FileUtils.rm( 
  [File.join(RAILS_ROOT, 'public', 'stylesheets', 'form.css')],
  :verbose => true
)