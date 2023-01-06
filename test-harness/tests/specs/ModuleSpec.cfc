component extends="coldbox.system.testing.BaseTestCase" appMapping="root" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
		super.beforeAll();
		setup();
	}

	function afterAll(){
		super.afterAll();
	}

	/*********************************** BDD SUITES ***********************************/

	function run(){
		describe( "Base module", function() {
			it( "should have testable SMTP creds", function() {
				expect( getUtil().getEnv( "SMTP_HOST" ) )
					.notToBeNull()
					.notToBe( "" );

				expect( getUtil().getEnv( "SMTP_PORT" ) )
					.notToBeNull()
					.notToBe( "" );

				expect( getUtil().getEnv( "SMTP_USERNAME" ) )
					.notToBeNull()
					.notToBe( "" );

				expect( getUtil().getEnv( "SMTP_PASSWORD" ) )
					.notToBeNull()
					.notToBe( "" );

			});
		});
	}

}
