component accessors="true"{

    property name="javaloader";
    property name="name" type="string";
    property name="properties" type="struct" setter="false";

    property name="Session" type="component";
    property name="Message" type="component";

    /**
     * Constructor
     *
     * @properties The protocol properties to instantiate
     */
    function init( struct properties = {} ){
        variables.properties = setDefaultProps( arguments.properties );
        variables.name = "SMTPProtocol";

        
        variables.javaloader = new cbjavaloader.models.Loader();
        variables.javaloader.appendPaths( expandPath( "/cbmailservices-smtp/lib/" ) );
        return this;
    }

    /**
     * Ensure some sane defaults exist; at least enough to prevent errors
     *
     * @props The configured protocol properties.
     */
    function setDefaultProps( required struct props ){
        param arguments.props.host = "127.0.0.1";
        param arguments.props.port = "25";
        param arguments.props.protocol = "smtp";
        param arguments.props.authentication = { enabled : false };
        param arguments.props.debug = false;

        return arguments.props;
    }

    /**
     * Implemented by concrete protocols to send a message.
     *
     * The return is a struct with a minimum of the following two keys
     * - `error` - A boolean flag if the message was sent or not
     * - `messages` - An array of messages the protocol stored if any when sending the payload
     *
     * @payload The paylod object to send the message with
     * @payload.doc_generic cbmailservices.models.Mail
     *
     * @return struct of { "error" : boolean, "messages" : [] }
     */
    struct function send( required cbmailservices.models.Mail payload ){
        var result = {
            "error" : false,
            "messages" : []
        };

        // The mail config data
        var mailParams    = arguments.payload.getConfig();
        // writeDump( mailParams );//abort;
// writeDump( getProperties() );
        var smtpProvider = variables.javaloader.create( "com.sun.mail.smtp.SMTPProvider" );
        var currentThread = createObject("java", "java.lang.Thread").currentThread();
        var tccl = currentThread.getContextClassLoader();
        currentThread.setContextClassLoader( smtpProvider.getClass().getClassLoader() );
        var mailSession = variables.javaLoader.create( "jakarta.mail.Session" )
                        .getDefaultInstance( buildSessionProps(), javaCast( "null", 0 ) );

        var RecipientType = variables.javaLoader.create( "jakarta.mail.internet.MimeMessage$RecipientType" );
        var Message = variables.javaLoader.create( "jakarta.mail.internet.MimeMessage" ).init( MailSession );

        Message.setRecipients( RecipientType.TO, mailParams.to );

        // writeDump( mailParams );abort;
        Message.setFrom( javaloader.create( "jakarta.mail.internet.InternetAddress" ).parse( mailParams.from ) );
        Message.setReplyTo( javaloader.create( "jakarta.mail.internet.InternetAddress" ).parse( mailParams.replyTo ) );
        Message.setSubject( mailParams.subject );
        Message.setText( "TEST email" );
        
        _send( Message )
        currentThread.setContextClassLoader( tccl );
        return result;
    }

    /**
     * Do the actual sending
     *
     * @Message Jakarta Message object
     */
    private function _send( required Message ){
        return variables.javaLoader.create( "jakarta.mail.Transport" )
            .send( 
                  Message    
                , getProperties().authentication.username
                , getProperties().authentication.password
            );
    }

    /**
     * configure SMTP connection details, among other things.
     * 
     * See https://jakarta.ee/specifications/mail/2.1/jakarta-mail-spec-2.1.html#a823 for a full list of supported properties.
     * 
     * @cite https://jakarta.ee/specifications/mail/2.1/jakarta-mail-spec-2.1.html#a823
     */
    private function buildSessionProps(){
        var props = createObject( "java", "java.util.Properties");

        /**
         * "THE PROPERTIES ARE ALWAYS SET AS STRINGS", according to the docs.
         * 
         * @cite https://jakarta.ee/specifications/mail/1.6/apidocs/javax/mail/package-summary.html
         */
        props.put( "mail.transport.protocol", "#getProperties().Protocol#" );
        
        props.put( "mail.#getProperties().Protocol#.host", "#getProperties().host#" );
        props.put( "mail.#getProperties().Protocol#.port", "#getProperties().port#" );
        props.put( "mail.debug", "#getProperties().Debug#" );

        // Is this required?? ❓
        props.put( "mail.#getProperties().Protocol#.auth", "true" );
        
        // Is this required?? ❓
        // props.put( "mail.#getProperties().Protocol#.starttls.enable", "true" );
        return props;
    }

}