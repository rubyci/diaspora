module Workers
  class ReceiveBase < Base
    sidekiq_options queue: :receive

    include Diaspora::Logging

    # don't retry for errors that will fail again
    def filter_errors_for_retry
      yield
    rescue DiasporaFederation::Entity::ValidationError,
           DiasporaFederation::Entity::InvalidRootNode,
           DiasporaFederation::Entity::InvalidEntityName,
           DiasporaFederation::Entity::UnknownEntity,
           DiasporaFederation::Entities::Relayable::SignatureVerificationFailed,
           DiasporaFederation::Entities::Participation::ParentNotLocal,
           DiasporaFederation::Federation::Receiver::InvalidSender,
           DiasporaFederation::Federation::Receiver::NotPublic,
           DiasporaFederation::Salmon::SenderKeyNotFound,
           DiasporaFederation::Salmon::InvalidEnvelope,
           DiasporaFederation::Salmon::InvalidSignature,
           DiasporaFederation::Salmon::InvalidAlgorithm,
           DiasporaFederation::Salmon::InvalidEncoding,
           Diaspora::Federation::AuthorIgnored,
           Diaspora::Federation::InvalidAuthor,
           # TODO: deprecated
           DiasporaFederation::Salmon::MissingMagicEnvelope,
           DiasporaFederation::Salmon::MissingAuthor,
           DiasporaFederation::Salmon::MissingHeader,
           DiasporaFederation::Salmon::InvalidHeader => e
      logger.warn "don't retry for error: #{e.class}"
    end
  end
end
