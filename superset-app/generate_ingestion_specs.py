import boto3
import jinja2
import os
import requests

s3 = boto3.resource('s3')
TEMPLATE_FILE = "forward_prices.json.j2"
druid_overlord_url = "http://druid-overlord.aws2-vpc-ss-dts.savvybi.enterprises:8090/druid/indexer/v1/task"

if __name__ == '__main__':
    templateLoader = jinja2.FileSystemLoader(searchpath="./")
    templateEnv = jinja2.Environment(loader=templateLoader)
    template = templateEnv.get_template(TEMPLATE_FILE)

    my_bucket = s3.Bucket('druid.dts.input-bucket')

    output_dir = "/tmp/ingestion_specs"
    if not os.path.exists(output_dir):
        os.mkdir(output_dir)

    for awsfile in my_bucket.objects.filter(Prefix='mkt_ASX_Forward_Prices'):
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
            print("posting: %s", (spec_name,))

            with open("/tmp/ingestion_specs/%s" % (spec_name,), 'rb') as f:
                #print(f.read())
                r = requests.post(druid_overlord_url, headers={'Content-Type':'application/json'}, data=f.read())
                print(r.text)
