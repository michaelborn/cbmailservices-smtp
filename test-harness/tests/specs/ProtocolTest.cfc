/**
 * The base model test case will use the 'model' annotation as the instantiation path
 * and then create it, prepare it for mocking and then place it in the variables scope as 'model'. It is your
 * responsibility to update the model annotation instantiation path and init your model.
 */
component
extends      ="tests.specs.BaseModelTest"
	appMapping   ="root"
	loadColdBox  =true
	unloadColdBox=false
{

	function run(){
		describe( "SMTP", function(){
			beforeEach( function() {
				if ( !variables.keyExists( "model" ) ){
					variables.model = createMock( "models.SMTPProtocol" ).init();
				}
			})
			it( "can instantiate via wirebox", function(){
				expect( getWirebox().getInstance( "SMTPProtocol@cbmailservices-smtp" ) ).toBeTypeOf( "component" );
			} );
			it( "will set sane defaults", function() {

				expect( variables.model.getProperties() ).toHaveKey( "host" );
				expect( variables.model.getProperties() ).toHaveKey( "port" );
				expect( variables.model.getProperties() ).toBeStruct().toHaveKey( "authentication" );
				expect( variables.model.getProperties().authentication ).toBeStruct().toHaveKey( "enabled" );
			});
			it( "can send email", function(){
				
				var model = new models.SMTPProtocol( getSMTPProps() );
				var result = model.send( getMail() );

                expect( result ).toBeStruct()
                                .toHaveKey( "error" )
                                .toHaveKey( "messages" );
			} );
			it( "sets right mail params", function() {
				var javaloader = variables.model.getJavaloader();
				var recipientTypes = javaloader.create( "jakarta.mail.internet.MimeMessage$RecipientType" );
				
				// get ahold of the sent jakarta.mail.Message object for testing
				variables.model.$( method = "_send", callback = ( Message ) => variables.sentMessage = arguments.Message );
				variables.model.send( getMail() );
				expect( isNull( variables.sentMessage ) ).toBeFalse();

				expect( variables.sentMessage.getRecipients( recipientTypes.TO ) ).toBe( "SMTP Mailer Test" );
				expect( arrayFirst( variables.sentMessage.getFrom() ).toString() ).toBe( "info@michaelborn.me" );
				expect( arrayFirst( variables.sentMessage.getReplyTo() ).toString() ).toBe( "michael-replyto@ortussolutions.com" );
				expect( variables.sentMessage.getSubject() ).toBe( "SMTP Mailer Test" );
				expect( variables.sentMessage.getContent() ).toBe( "I am writing you about your car's extended warranty." );
			});
		} );
	}

	private Mail function getMail(){
		return getInstance( "MailService@cbmailservices" ).newMail(
			subject = "SMTP Mailer Test",
			to = "michael@ortussolutions.com",
			replyto = "michael-replyto@ortussolutions.com",
			from = "info@michaelborn.me",
			body = "I am writing you about your car's extended warranty."
		);
	}

	private struct function getSMTPProps(){
		return {
			"host" : server.system.environment[ "SMTP_HOST" ],
			"port" : server.system.environment[ "SMTP_PORT" ],
			"authentication" : {
				"enabled" : true,
				"username" : server.system.environment[ "SMTP_USERNAME" ],
				"password" : server.system.environment[ "SMTP_PASSWORD" ]
			}
		};
	}

}