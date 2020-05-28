import React, { Component } from 'react';

export class FetchData extends Component {
  static displayName = FetchData.name;

  constructor(props) {
    super(props);
    this.state = { transactions: [], loading: true, granularity: 1 };
    this.createChatRow = this.createChatRow.bind(this);
    this.renderChatTable = this.renderChatTable.bind(this);
    this.handleGranularityChange = this.handleGranularityChange.bind(this);
  }

  componentDidMount() {
    this.populateChatData();
  }

  handleGranularityChange = (e) => {
    this.setState({
      granularity: e.currentTarget.value
    }, () => {
        this.populateChatData();
    })
  }

  createChatRow = (t) => {
    if (this.state.granularity == 1)
      return FetchData.createTransactionRow(t);
    else
      return FetchData.createAggregatedRow(t);
  }

  renderChatTable = (transactions) => {
    return (
      <div>
        <table>
          <tbody>
          <tr>
              <td><input type="radio" name="aggregate" value="1" checked={this.state.granularity==1} onChange={this.handleGranularityChange} /><label>1 minute</label></td>
              <td><input type="radio" name="aggregate" value="30" checked={this.state.granularity == 30} onChange={this.handleGranularityChange} /><label>30 minutes</label></td>
              <td><input type="radio" name="aggregate" value="60" checked={this.state.granularity == 60} onChange={this.handleGranularityChange} /><label>1 h</label></td>
              <td><input type="radio" name="aggregate" value="240" checked={this.state.granularity == 240} onChange={this.handleGranularityChange} /><label>4 h</label></td>
              <td><input type="radio" name="aggregate" value="1440" checked={this.state.granularity == 1440} onChange={this.handleGranularityChange} /><label>24 h</label></td>
            </tr>
          </tbody>
        </table>
        <table className='table table-striped' aria-labelledby="tabelLabel">
          <tbody>
            {
              transactions.map(t => this.createChatRow(t) )
            }
          </tbody>
          </table>
        </div>
    );
  }

  static createTransactionRow(t) {
    let eventText = t.date + ": ";
    switch (t.eventType) {
      case 'enter-the-room':
        eventText += t.userName + " enters the room.";
        break;
      case 'leave-the-room':
        eventText += t.userName + " leaves the room.";
        break;
      case 'comment':
        eventText += t.userName + " comments: " + t.text;
        break;
      case 'high-five-another-user':
        eventText += t.userName + " high gives: " + t.targetUserName;
        break;
    }
    return (<tr><td>{eventText}</td></tr>);
  }

  static createAggregatedRow(t) {
    let eventText = (
      <div>
        <span>{t.startDate}<br /></span>
        <span>{String(t.enter)} entered the room<br /></span>
        <span>{String(t.leave)} left<br /></span>
        <span>{String(t.hiFive)} person high-fived other person<br /></span>
        <span>{String(t.comment)} comments<br /></span>
      </div>);
    return (<tr><td>{eventText}</td></tr>);
  }

  render() {
    let contents = this.state.loading
      ? <p><em>Loading...</em></p>
      : this.renderChatTable(this.state.transactions);

    return (
      <div>
        <h1 id="tabelLabel" >Chat events data aggregation</h1>
        <p>This component aggregates chat messages using an ETL approach.</p>
        {contents}
      </div>
    );
  }

  async populateChatData() {
    let endpoint = '/event/geteventtransactions';
    if (this.state.granularity > 1)
      endpoint = '/event/geteventaggregated?minutes=' + this.state.granularity;
    const response = await fetch(endpoint);
    const data = await response.json();
    this.setState({ transactions: data, loading: false });
  }
}
