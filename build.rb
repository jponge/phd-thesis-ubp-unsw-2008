#!/usr/bin/env ruby

require 'optparse'
require 'fileutils'

MAIN_FILE = "phd-thesis"
PDFLATEX  = "pdflatex #{MAIN_FILE}.tex"
BIBTEX    = "bibtex #{MAIN_FILE}"

def build_pdf
  return unless system PDFLATEX
  return unless system BIBTEX
  callcc do |stop_build|
    3.times do
      status = system PDFLATEX
      stop_build.call unless status
    end
  end
end

def single_compilation
  system PDFLATEX
end

def clean_artifacts
  extensions = %w[blg log pdf aux bbl lof lot out toc tps]
  files = extensions.map { |ext| "#{MAIN_FILE}.#{ext}" }
  FileUtils::Verbose::rm files, { :force => true }
end

def open_pdf(how)
  system "#{how} #{MAIN_FILE}.pdf"
end

def run
  options = {
    :command => :pdf
  }
  OptionParser.new do |opts|
    opts.banner = "Usage: build.rb [options]"
  
    opts.on("--pdf", "Build the PDF output (default)") do |pdf|
      options[:command] = :pdf
    end
    
    opts.on("--oneshot", "Single LaTeX compilation") do |oneshot|
      options[:command] = :oneshot
    end
    
    opts.on("--doubleshot", "Double LaTeX compilation") do |oneshot|
      options[:command] = :doubleshot
    end
  
    opts.on("--clean", "Clean the build artifacts") do |clean|
      options[:command] = :clean
    end
    
    opts.on("--open-pdf [HOW]", "Open the generated PDF with HOW)") do |how|
      options[:openpdf] = how
    end
  
    opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      exit
    end
  end.parse!

  case options[:command]

  when :pdf
    build_pdf
    open_pdf(options[:openpdf]) if options[:openpdf]
  
  when :oneshot
    single_compilation
    open_pdf(options[:openpdf]) if options[:openpdf]
    
  when :doubleshot
    2.times { single_compilation }
    open_pdf(options[:openpdf]) if options[:openpdf]
    
  when :clean
    clean_artifacts
    
  end  
  
end

run
