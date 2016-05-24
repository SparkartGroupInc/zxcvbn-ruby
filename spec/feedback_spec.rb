require 'spec_helper'

describe Zxcvbn::Feedback do
  {
    "friend" => {warning: "A word by itself is easy to guess", suggestions: ["Add another word or two. Uncommon words are better."]}, # dictionary, generic
    "qwerty" => {warning: "This is a top-10 common password", suggestions: ["Add another word or two. Uncommon words are better."]}, # dictionary, top 10
    "secret" => {warning: "This is a top-100 common password", suggestions: ["Add another word or two. Uncommon words are better."]}, # dictionary, top 100
    "bones" => {warning: "This is a very common password", suggestions: ["Add another word or two. Uncommon words are better."]}, # dictionary, common
    "gabriel" => {warning: "Names and surnames by themselves are easy to guess", suggestions: ["Add another word or two. Uncommon words are better."]}, # dictionary, common name
    "gabriel123" => {warning: "Common names and surnames are easy to guess", suggestions: ["Add another word or two. Uncommon words are better."]}, # dictionary, common name with number
    "Password" => {warning: "This is a top-10 common password", suggestions: ["Add another word or two. Uncommon words are better.", "Capitalization doesn't help very much"]}, # dictionary, capitalization
    "PASSWORD" => {warning: "This is a top-10 common password", suggestions: ["Add another word or two. Uncommon words are better.", "All-uppercase is almost as easy to guess as all-lowercase"]}, # dictionary, all caps
    "P4SSW0RD" => {warning: "", suggestions: ["Add another word or two. Uncommon words are better.", "Predictable substitutions like '@' instead of 'a' don't help very much"]}, # dictionary, l33t
    "lkjhg" => {warning: "Straight rows of keys are easy to guess", suggestions: ["Add another word or two. Uncommon words are better.", "Use a longer keyboard pattern with more turns"]}, # spacial
    "lkjhgtyu" => {warning: "Short keyboard patterns are easy to guess", suggestions: ["Add another word or two. Uncommon words are better.", "Use a longer keyboard pattern with more turns"]}, # spacial, with turns
    "aaaa" => {warning: "Repeats like \"aaa\" are easy to guess", suggestions: ["Add another word or two. Uncommon words are better.", "Avoid repeated words and characters"]}, # repeat
    "abc" => {warning: "Sequences like abc or 6543 are easy to guess", suggestions: ["Add another word or two. Uncommon words are better.", "Avoid sequences"]}, # sequence
    "2007" => {warning: "Years are easy to guess", suggestions: ["Add another word or two. Uncommon words are better.", "Avoid years"]}, # year
    "2u8" => {warning: "Small passwords are easily bruteforced", suggestions: ["Add another word or two. Uncommon words are better.", "Avoid small passwords that can be bruteforced easily"]}, # bruteforce
    "03/15/2007" => {warning: "Dates are easy to guess", suggestions: ["Add another word or two. Uncommon words are better.", "Avoid dates"]}, # date
    "4$kn@pkd@0BG" => {warning: "", suggestions: []} # valid
  }.each do |password, expected_feedback|
    context "with #{password}" do
      it "returns correct feedback" do
        data = Zxcvbn::Data.new
        omnimatch = Zxcvbn::Omnimatch.new(data)
        scorer = Zxcvbn::Scorer.new(data)
        matches = omnimatch.matches(password)
        result = scorer.minimum_entropy_match_sequence(password, matches)
        feedback = Zxcvbn::Feedback.new(result)
        expect(feedback.warning).to eq(expected_feedback[:warning])
        expect(feedback.suggestions).to eq(expected_feedback[:suggestions])
      end
    end
  end
end