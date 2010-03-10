# start at LabeledFormBuilder
require 'labeled_form_builder'

require 'labeled_form_helper'

require 'custom_error_helper'

ActionView::Base.send :include, LabeledFormHelper
