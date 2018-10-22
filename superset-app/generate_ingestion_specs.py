import boto3
import jinja2
import os
import requests
import argparse
import sys

s3 = boto3.resource('s3')
druid_overlord_url = "http://druid-overlord.aws2-vpc-ss-dts.savvybi.enterprises:8090/druid/indexer/v1/task"

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Process some integers.')
    parser.add_argument('--template-file', dest='template_file', help='the template file to use')
    parser.add_argument('--bucket-prefix', dest='bucket_prefix', help='the prefix to use for the s3 bucket')
    args = parser.parse_args()

    print(args)

    if not args.template_file:
        print('--template-file is required')
        sys.exit(1)

    if not args.bucket_prefix:
        print('--bucket-prefix is required')
        sys.exit(1)

    templateLoader = jinja2.FileSystemLoader(searchpath="./")
    templateEnv = jinja2.Environment(loader=templateLoader)
    template = templateEnv.get_template(args.template_file)

    my_bucket = s3.Bucket('druid.dts.input-bucket')

    output_dir = "/tmp/ingestion_specs"
    if not os.path.exists(output_dir):
        os.mkdir(output_dir)


    for awsfile in my_bucket.objects.filter(Prefix=args.bucket_prefix):
        print(awsfile.key)

        outputText = template.render(csv_file_name=awsfile.key)
        out_name = awsfile.key.split('/')[1]
        out_name = out_name.replace('-', '_')

        print(outputText)
        with open("/tmp/ingestion_specs/%s.json" % (out_name,), "w") as output_file:
            output_file.write(outputText)

    print("ingestion specs created..")

    #curl -X 'POST' -H 'Content-Type:application/json' -d @superset-app/market-data-test.json http://druid-overlord.aws2-vpc-ss-dts.savvybi.enterprises:8090/druid/indexer/v1/task
    for f in os.listdir(output_dir):
        if os.path.isfile(os.path.join(output_dir, f)):
            spec_name = f
            print("posting: %s" % (spec_name,))

            with open("/tmp/ingestion_specs/%s" % (spec_name,), 'rb') as f:
                #print(f.read())
                r = requests.post(druid_overlord_url, headers={'Content-Type':'application/json'}, data=f.read())
                print(r.text)
