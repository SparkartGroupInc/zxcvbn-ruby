# Derived from logic located here: https://github.com/dropbox/zxcvbn/blob/master/src/feedback.coffee

module Zxcvbn
  class Feedback
    attr_accessor :warning, :suggestions
    def initialize(results)
      feedback = process_results(results)
      self.warning = feedback[:warning]
      self.suggestions = feedback[:suggestions]
    end

    private

    def process_results(results)
      match_sequences = results.match_sequence.sort{|match_sequence| match_sequence.token.size}
      longest_sequence = match_sequences.last
      return {warning: '', suggestions: ['Use a few words, avoid common phrases', 'No need for symbols, digits, or uppercase letters']} if match_sequences.size == 0
      return {warning: '', suggestions: []} if results.score > 2

      extra_feedback = 'Add another word or two. Uncommon words are better.'
      feedback = get_feedback_for_match_sequence(longest_sequence, match_sequences.size == 1)
      feedback[:suggestions].unshift(extra_feedback)

      return feedback
    end

    def get_feedback_for_match_sequence(match_sequence, is_sole_match)
      case match_sequence.pattern
      when 'dictionary'
        get_dictionary_match_feedback(match_sequence, is_sole_match)
      when 'spatial'
        {warning: match_sequence.turns == 1 ? 'Straight rows of keys are easy to guess' : 'Short keyboard patterns are easy to guess', suggestions: ['Use a longer keyboard pattern with more turns']}
      when 'repeat'
        {warning: 'Repeats like "aaa" are easy to guess', suggestions: ['Avoid repeated words and characters']}
      when 'sequence'
        {warning: 'Sequences like abc or 6543 are easy to guess', suggestions: ['Avoid sequences']}
      when 'year'
        {warning: "Years are easy to guess", suggestions: ['Avoid years']}
      when 'bruteforce'
        {warning: "Small passwords are easily bruteforced", suggestions: ['Avoid small passwords that can be bruteforced easily']}
      when 'date'
        {warning: "Dates are easy to guess", suggestions: ['Avoid dates']}
      else
        {warning: "", suggestions: []}
      end
    end

    def get_dictionary_match_feedback(match_sequence, is_sole_match)
      warning = begin
        if match_sequence.dictionary_name == 'passwords'
          if is_sole_match && !match_sequence.l33t
            if match_sequence.rank <= 10
              'This is a top-10 common password'
            elsif match_sequence.rank <= 100
              'This is a top-100 common password'
            else
              'This is a very common password'
            end
          end
        elsif match_sequence.dictionary_name == 'english'
          if is_sole_match
            'A word by itself is easy to guess'
          end
        elsif ['surnames', 'male_names', 'female_names'].include?(match_sequence.dictionary_name)
          if is_sole_match
            'Names and surnames by themselves are easy to guess'
          else
            'Common names and surnames are easy to guess'
          end
        end
      end

      warning ||= ""

      suggestions = []
      word = match_sequence.token
      if word.match(Zxcvbn::Entropy::START_UPPER)
        suggestions << "Capitalization doesn't help very much"
      elsif word.match(Zxcvbn::Entropy::ALL_UPPER)
        suggestions << "All-uppercase is almost as easy to guess as all-lowercase"
      end
      if match_sequence.l33t
        suggestions << "Predictable substitutions like '@' instead of 'a' don't help very much"
      end
      {warning: warning, suggestions: suggestions}
    end
  end
end