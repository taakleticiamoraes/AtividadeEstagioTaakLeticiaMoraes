import { LightningElement, track, wire } from "lwc";
import getFAQs from "@salesforce/apex/FAQController.getFAQs";

export default class FaqPage extends LightningElement {
  @track faqs = [];
  @track searchTerm = "";
  @track pageNumber = 1;
  @track totalRecords = 0;

  pageSize = 10;
  delayTimeout;

  @wire(getFAQs, {
    searchTerm: "$searchTerm",
    pageNumber: "$pageNumber",
    pageSize: "$pageSize"
  })
  wiredFAQs({ error, data }) {
    if (data) {
      this.faqs = data.faqList;
      this.totalRecords = data.totalRecords;
    } else if (error) {
      console.error("Erro ao buscar FAQs:", error);
    }
  }

  handleSearchChange(event) {
    window.clearTimeout(this.delayTimeout);
    const searchKey = event.target.value;

    // eslint-disable-next-line @lwc/lwc/no-async-operation
    this.delayTimeout = setTimeout(() => {
      this.searchTerm = searchKey;
      this.pageNumber = 1;
    }, 1000);
  }

  handlePrevious() {
    if (this.pageNumber > 1) {
      this.pageNumber--;
    }
  }

  handleNext() {
    if (this.pageNumber < this.totalPages) {
      this.pageNumber++;
    }
  }

  get totalPages() {
    return Math.ceil(this.totalRecords / this.pageSize) || 1;
  }

  get isFirstPage() {
    return this.pageNumber === 1;
  }

  get isLastPage() {
    return this.pageNumber >= this.totalPages;
  }

  get hasRecords() {
    return this.faqs && this.faqs.length > 0;
  }
}
