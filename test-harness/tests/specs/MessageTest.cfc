/**
 * The base model test case will use the 'model' annotation as the instantiation path
 * and then create it, prepare it for mocking and then place it in the variables scope as 'model'. It is your
 * responsibility to update the model annotation instantiation path and init your model.
 */
component
	extends      ="BaseModelTest"
	appMapping   ="root"
	loadColdBox  =true
	unloadColdBox=false
    model="cbmailservices-smtp.models.Message"
{

	function run(){
        describe( "Message", function() {
			it ( "Can initialize", function() {
				expect( variables.model ).toBeComponent().toBeInstanceOf( "cbmailservices-smtp.models.Message" );
			});
		});
    }

}