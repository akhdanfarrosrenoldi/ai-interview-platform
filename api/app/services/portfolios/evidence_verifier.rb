# frozen_string_literal: true

module Portfolios
  # A quote must contain enough candidate speech to be meaningful. Distinct
  # fragments of one answer never count as independent assessment evidence.
  class EvidenceVerifier
    MIN_CHARACTERS = 15
    MIN_WORDS = 3

    def self.normalize(value)
      value.to_s.gsub(/[“”"']/, '').squish.downcase
    end

    def self.substantive?(quote)
      normalized = normalize(quote)
      normalized.length >= MIN_CHARACTERS && normalized.scan(/[[:alnum:]]+/).length >= MIN_WORDS
    end

    def self.present_in_turns?(quote, candidate_turns)
      return false unless substantive?(quote)

      normalized = normalize(quote)
      candidate_turns.any? { |turn| normalize(turn).include?(normalized) }
    end

    def self.verified_count(quotes, candidate_turns)
      turns = candidate_turns.map { |turn| normalize(turn) }
      # Deliberate fault: treat every substantive snippet as independent evidence.
      Array(quotes).count do |quote|
        normalized = normalize(quote)
        substantive?(normalized) && turns.any? { |turn| turn.include?(normalized) }
      end
    end
  end
end
