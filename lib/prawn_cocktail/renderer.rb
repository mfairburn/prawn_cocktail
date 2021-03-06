require "prawn"
require_relative "template"
require_relative "utils/recursive_closed_struct"

module PrawnCocktail
  class Renderer
    def initialize(template_name, data, initializers)
      @prawn_document_options = {}
      @template_name = template_name
      @data = data
      @initializers = initializers
    end

    def meta(opts)
      @prawn_document_options.merge!(opts)
    end

    def content(&block)
      @initializers.each do |proc|
        prawn_document.instance_eval(&proc)
      end

      prawn_document.instance_exec(data_object, &block)
    end

    def render_data
      apply_template
      prawn_document.render
    end

    def render_file(file)
      apply_template
      prawn_document.render_file(file)
    end

    private

    def apply_template
      Template.new(@template_name).apply(self)
    end

    def prawn_document
      @doc ||= Prawn::Document.new(prawn_document_options)
    end

    def prawn_document_options
      @prawn_document_options || {}
    end

    def data_object
      RecursiveClosedStruct.new(@data)
    end
  end
end
