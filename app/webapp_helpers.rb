module Branchinator
  module WebAppHelpers
    def current_user
      current_session.user
    end

    def current_session
      @current_session ||= catch(:no_session) {
        token = session['access_token']
        token ||= env['HTTP_AUTHORIZATION'].match(/^Bearer (.+)$/)[1] rescue nil
        throw :no_session if token.nil?
        session = Session.find_by(token: token, active: true)
        throw :no_session if session.nil?
        request_reauth! unless session.age < ENV['SESSION_LIFETIME'].to_f
        session
      } || NullSession.new
    end
    alias :ensure_session_trust! :current_session

    def request_reauth!
      halt(419, {
        error: "IdentityUncertain",
        developerMessage: "The access token provided is no longer trusted enough for this action."
      })
    end

    def authd_only!
      halt(401, {
        error: "NotAuthenticated",
        developerMessage: "No valid authentication token was given."
      }) if current_user.nil?
    end

    def username_from_auth(auth)
      auth.info.nickname || [auth.provider, auth.uid].join("-")
    end

    def json_list_of(list)
      list.extend(Serializer)
      {
        count: list.count,
        items: list.serializers,
        links: {}
      }.to_json(root: false)
    end
  end
end