#Kevin Wojcik
#CCS CS 130a
#Spring 2012

require 'rubygems'
require 'nokogiri'
require 'open-uri'

URL = "http://www.slugbooks.com"

def scrape_course(course_url)
        #Get the course specific web page
        course_doc = Nokogiri::HTML(open(course_url))

        #Go through each book for the course
        course_doc.css(".first").each do |book|
                #Some non books use the same CSS class so we need to filter those
                if book.at_css(".title") != nil

                        #All the attributes for a specific book
                        children = book.element_children()

                        #Parse and print out the URL for the image of the book
                        puts URL + children[0].css('img')[0]['src']

                        #Parse and print out the name of the book
                        puts children[1].text.gsub(/\s+/, ' ')[0, children[1].text.index("|") - 1]

                        #Parse and print out the author of the book
                        puts children[3].text[4, children[3].text.length].gsub(/\s+/, ' ')

                        #Parse and print out the ISBN of the book
                        puts children[4].text[6, 13].gsub(/\s+/, ' ') + "\n\n"
                end
        end
end

def scrape_department(department_url)
        #Open the web page for a particular department
        department_doc = Nokogiri::HTML(open(department_url))

        #Go through all courses in that department
        department_doc.css(".middleclasslinks").css('li').each do |course|

                #Print the name of the course
                puts course.text.gsub(/\s+/, ' ').strip

                #Build the new URL for the course
                course_url = URL + course.css('a')[0]['href']

                #Scrape the course
                scrape_course(course_url)
        end

end

def scrape_school(school_url)
        #Open the page for a particular school
        school_doc = Nokogiri::HTML(open(school_url))

        #Go through each department at a school
        school_doc.css(".bottomlinks").css('li').each do |department|

                #Print the name of the department
                #puts department.text.gsub(/\s+/, ' ').strip

                #Build the new URL for the department
                department_url = URL + department.css('a')[0]['href']

                #Scrape the Department
                scrape_department(department_url)
        end
end

def scrape_state(state_url)
        #Open the page for a particular state
        states_doc = Nokogiri::HTML(open(state_url))

        #Go through each school in the state
        states_doc.css(".middlelinks").css('li').each do |school|
                #Print out the name of the school
                #puts school.text.gsub(/\s+/, ' ').strip

                #Build the new URL for the school
                school_url = URL + school.css('a')[0]['href']

                #Scrape the school
                scrape_school(school_url)
        end
end

def scrape_all()
        #Open the web page
        doc = Nokogiri::HTML(open(URL))

        #Get all the URLS at the bottom of the page, each representing a US state
        doc.css(".bottomlinks").css('li').each do |state|
                #Print out the name of the State
                #puts state.text.gsub(/\s+/, ' ').strip

                #Build the new URL from the base and the one listed in the <a href="..."/>
                state_url = URL + state.css('a')[0]['href']

                #Scrape the state
                scrape_state(state_url)
        end
end

#Help message for the command line
help = "[-state url_for_state] Parses only data for that specific state
[-school url_for_school] Parses only data for the school. Takes precedence over state
[-department url_for_department] Parses only data for the department. Takes precedence over school
[-course url_for_course] Parses only data for the course. Takes precedence over department\n"

#Stores the URLs for the specific request if used
command_line_state = nil
command_line_school = nil
command_line_department = nil
command_line_course = nil

#Check for the -h argument
if ARGV.length == 1 and ARGV[0] == "-h"
	puts help
	exit
end

#Check to make sure that we have pairs of arguments
if ARGV.length % 2 != 0
	puts "Bad parameters"
	exit
end

ARGV.each_index do |i|
	if i % 2 == 1
		next
	end

	if ARGV[i] == "-state"
		command_line_state = ARGV[i+1]
	elsif ARGV[i] == "-school"
		command_line_school = ARGV[i+1]
	elsif ARGV[i] == "-department"
		command_line_department = ARGV[i+1]
	elsif ARGV[i] == "-course"
		command_line_course = ARGV[i+1]
	else
		puts "Unknown parameter " + ARGV[i]
		exit
	end
	
end

if command_line_course != nil
	scrape_course(command_line_course)
elsif command_line_department != nil
	scrape_department(command_line_department)
elsif command_line_school != nil
	scrape_school(command_line_school)
elsif command_line_state != nil
	scrape_state(command_line_state)
else
	scrape_all()

end