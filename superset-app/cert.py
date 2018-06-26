from acm_factory import DNSValidatedACMCertClient

cert_client = DNSValidatedACMCertClient(domain='superset.savvybi.enterprises', region='ap-southeast-2') # defaults to using the 'default` aws profile on your machine and the 'us-east-1' aws region.
arn = cert_client.request_certificate(domain='superset.savvybi.enterprises')
cert_client.wait_for_certificate_validation(certificate_arn=arn, sleep_time=5, timeout=600) # will wait until the certificate is validated before continuing
