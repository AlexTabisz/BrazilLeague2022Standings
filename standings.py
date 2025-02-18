import json
import boto3
import http.client
import os


def lambda_handler(event, context):
    try:
        api_host = "v3.football.api-sports.io"
        api_path = api_path = "/standings?league=71&team=131&season=2022"
        api_key= os.getenv("STANDINGS_API_KEY")
        sns_topic_arn = os.getenv("SNS_TOPIC_ARN")
        sns_client = boto3.client("sns")
        
        conn = http.client.HTTPSConnection(api_host)
        headers = {
            'x-rapidapi-host': api_host,
            'x-rapidapi-key': api_key
        }

        conn.request("GET", api_path, headers=headers)
        res = conn.getresponse()
        data = res.read().decode("utf-8")

        if res.status == 200:
            standings_data = json.loads(data)

            try:
                league_name = standings_data['response'][0]['league']['name']
                country = standings_data['response'][0]['league']['country']
                season = standings_data['response'][0]['league']['season']
                rank = standings_data['response'][0]['league']['standings'][0][0]['rank']
                team_name = standings_data['response'][0]['league']['standings'][0][0]['team']['name']
                points = standings_data['response'][0]['league']['standings'][0][0]['points']

                output_data = f"""
                League Name: {league_name}
                Country: {country}
                Season: {season}
                Rank: {rank}
                Team Name: {team_name}
                Points: {points}
                """
            except Exception as e:
                print(f"Error fetching data from API: {e}")
                return {"statusCode": 500, "body": "Error fetching data"}

            try:
                sns_client.publish(
                    TopicArn=sns_topic_arn,
                    Message=output_data
                )
            except Exception as e:
                print(f"Error publishing to SNS: {e}")
                return {"statusCode": 500, "body": "Error publishing to SNS"}
            
            return {"statusCode": 200, "body": "Data processed and sent to SNS"}

        else:
            print(f"API call failed with status code: {res.status}")
            return None

    except Exception as e:
        print(f"An error occurred: {str(e)}")
        return None
            
    